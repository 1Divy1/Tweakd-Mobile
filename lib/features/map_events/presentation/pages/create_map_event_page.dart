import 'package:tweakd/core/di/injection.dart';
import 'package:tweakd/core/services/image_service.dart';
import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/map_event.dart';
import '../bloc/create_event/bloc.dart';
import '../bloc/create_event/event.dart';
import '../bloc/create_event/state.dart';
import '../utils/map_event_error_mapper.dart';
import '../widgets/create/create_event_chrome.dart';
import '../widgets/create/steps/basics_step.dart';
import '../widgets/create/steps/contests_step.dart';
import '../widgets/create/steps/cover_step.dart';
import '../widgets/create/steps/organizers_step.dart';
import '../widgets/create/steps/review_step.dart';
import '../widgets/create/steps/rules_step.dart';
import '../widgets/create/steps/when_where_step.dart';

/// The "new event" wizard — one screen per group of fields, in the same shape
/// as onboarding and the add-car flow — and the same wizard in edit mode.
///
/// The text controllers live here rather than in the bloc: a
/// `TextEditingController` is presentation state (cursor, selection, IME
/// composition), and rebuilding one from bloc state on every keystroke fights
/// the keyboard. The step index lives here too, for the same reason — it is
/// where the user is, not what the event is.
class CreateMapEventPage extends StatefulWidget {
  /// Set when editing an existing event. Editing is only permitted while the
  /// event is pending or rejected — the router only ever offers it then.
  final MapEventEntity? editEvent;

  const CreateMapEventPage({super.key, this.editEvent});

  @override
  State<CreateMapEventPage> createState() => _CreateMapEventPageState();
}

class _CreateMapEventPageState extends State<CreateMapEventPage> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _capacity = TextEditingController();

  /// One controller per rule row, kept aligned with the bloc's list by index.
  final List<TextEditingController> _rules = [];

  final _imageService = getIt<ImageService>();

  /// Every step shares one scroll view, so moving between them has to put the
  /// user back at the top of the new content.
  final _scroll = ScrollController();

  int _stepIndex = 0;

  /// Guards the one-time seeding of the controllers, from an edited event or a
  /// restored draft: the listener fires on every state change, and re-seeding
  /// would fight typing.
  bool _seeded = false;

  /// So the "picked up where you left off" note is shown once, not on every
  /// rebuild.
  bool _announcedDraft = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _capacity.dispose();
    for (final controller in _rules) {
      controller.dispose();
    }
    _scroll.dispose();
    super.dispose();
  }

  /// Fills the controllers from bloc state. Runs for an edited event and for a
  /// restored draft alike — in both cases the bloc holds text the user did not
  /// type in this session.
  void _seed(CreateMapEventState state) {
    if (_seeded) return;
    if (!state.isEditing && !state.restoredFromDraft) return;

    _seeded = true;
    _title.text = state.title;
    _description.text = state.description;
    _capacity.text = state.capacity?.toString() ?? '';
    _syncRuleControllers(state.rules.length);
    for (var i = 0; i < state.rules.length; i++) {
      _rules[i].text = state.rules[i];
    }
  }

  void _syncRuleControllers(int count) {
    while (_rules.length < count) {
      _rules.add(TextEditingController());
    }
    while (_rules.length > count) {
      _rules.removeLast().dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.bg,
      resizeToAvoidBottomInset: true,
      body: BlocConsumer<CreateMapEventBloc, CreateMapEventState>(
        listener: (context, state) {
          _seed(state);
          _syncRuleControllers(state.rules.length);

          if (state.restoredFromDraft && !_announcedDraft) {
            _announcedDraft = true;
            _snack(context, l10n.mapEventsDraftRestored);
          }

          final error = state.error;
          if (error != null) {
            _snack(context, mapEventErrorMessage(l10n, error));
            context
                .read<CreateMapEventBloc>()
                .add(const ClearCreateEventError());
          }
        },
        builder: (context, state) {
          if (state.status == CreateEventStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == CreateEventStatus.failure) {
            return _LoadFailed(state: state);
          }
          if (state.status == CreateEventStatus.success) {
            return _SubmittedView(state: state);
          }

          final steps = state.steps;
          // A restored draft or an edit can leave the index past the end when
          // the step list shrinks (edit mode drops CONTESTS).
          final index = _stepIndex.clamp(0, steps.length - 1);
          final step = steps[index];
          final isLast = index == steps.length - 1;
          final blocker = state.blockerFor(step);

          return SafeArea(
            child: Column(
              children: [
                CreateEventTopBar(
                  step: index,
                  stepCount: steps.length,
                  onClose: () => _close(context, state),
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: kCreateEventMaxWidth,
                      ),
                      child: ListView(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                        children: [_stepBody(step, state)],
                      ),
                    ),
                  ),
                ),
                CreateEventBottomBar(
                  canGoBack: index > 0,
                  isLastStep: isLast,
                  isSubmitting: state.isSubmitting,
                  backLabel: l10n.mapEventsWizardBack,
                  nextLabel: state.isSubmitting
                      ? l10n.mapEventsSubmitting
                      : isLast
                          ? (state.isEditing
                              ? l10n.mapEventsSaveCta
                              : l10n.mapEventsPublishCta)
                          : l10n.mapEventsWizardNext,
                  blocker: _blockerText(l10n, blocker) ??
                      _blockerText(l10n, state.validationMessage),
                  onBack: () => _goTo(index - 1),
                  onNext: () => _next(context, state, steps, index, isLast),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _stepBody(CreateEventStep step, CreateMapEventState state) {
    return switch (step) {
      CreateEventStep.basics => BasicsStep(
          state: state,
          titleController: _title,
          descriptionController: _description,
        ),
      CreateEventStep.organizers => OrganizersStep(state: state),
      CreateEventStep.whenWhere => WhenWhereStep(state: state),
      CreateEventStep.rules => RulesStep(
          state: state,
          capacityController: _capacity,
          ruleControllers: _rules,
        ),
      CreateEventStep.contests => ContestsStep(state: state),
      CreateEventStep.cover => CoverStep(
          state: state,
          onPick: () => _pickCover(context),
        ),
      CreateEventStep.review => ReviewStep(
          state: state,
          onEdit: (target) {
            final at = state.steps.indexOf(target);
            if (at >= 0) _goTo(at);
          },
        ),
    };
  }

  /// Advances, or submits on the last step. A step that isn't in order doesn't
  /// move — the bottom bar is already naming what's missing.
  void _next(
    BuildContext context,
    CreateMapEventState state,
    List<CreateEventStep> steps,
    int index,
    bool isLast,
  ) {
    FocusScope.of(context).unfocus();

    if (state.blockerFor(steps[index]) != null) return;

    if (!isLast) {
      _goTo(index + 1);
      return;
    }
    context.read<CreateMapEventBloc>().add(const SubmitMapEvent());
  }

  void _goTo(int index) {
    if (index < 0) return;
    setState(() => _stepIndex = index);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  /// Leaving is offered, not taken: the draft survives, so the only real
  /// question is whether to keep it.
  Future<void> _close(BuildContext context, CreateMapEventState state) async {
    final l10n = AppLocalizations.of(context)!;

    // Editing writes no draft, and a blank form has nothing to lose.
    if (state.isEditing || !_hasContent(state)) {
      context.pop();
      return;
    }

    final bloc = context.read<CreateMapEventBloc>();
    final choice = await showDialog<_LeaveChoice>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kCreateEventRadius),
        ),
        title: Text(l10n.mapEventsWizardDiscardTitle),
        content: Text(l10n.mapEventsWizardDiscardBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.mapEventsWizardStay),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(_LeaveChoice.discard),
            style: TextButton.styleFrom(foregroundColor: AppColors.accentHot),
            child: Text(l10n.mapEventsWizardDiscardDraft),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(_LeaveChoice.keep),
            style: TextButton.styleFrom(foregroundColor: AppColors.accent),
            child: Text(l10n.mapEventsWizardKeepDraft),
          ),
        ],
      ),
    );

    if (choice == null || !mounted) return;
    if (choice == _LeaveChoice.discard) bloc.add(const DiscardEventDraft());
    if (context.mounted) context.pop();
  }

  bool _hasContent(CreateMapEventState state) =>
      state.title.trim().isNotEmpty ||
      state.description.trim().isNotEmpty ||
      state.position != null ||
      state.startsAt != null ||
      state.cover != null ||
      state.rules.isNotEmpty ||
      state.pendingOrganizers.isNotEmpty ||
      state.pendingContests.isNotEmpty;

  Future<void> _pickCover(BuildContext context) async {
    final bloc = context.read<CreateMapEventBloc>();
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    // Compression starts immediately and runs while the rest of the wizard is
    // filled in, so submitting doesn't wait on it.
    bloc.add(
      ChangeEventCover(CompressedImage.compress(file.path, _imageService)),
    );
  }

  static void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static String? _blockerText(AppLocalizations l10n, String? key) =>
      switch (key) {
        CreateEventValidation.titleRequired => l10n.mapEventsValidationTitle,
        CreateEventValidation.descriptionRequired =>
          l10n.mapEventsValidationDescription,
        CreateEventValidation.locationRequired =>
          l10n.mapEventsValidationLocation,
        CreateEventValidation.startRequired => l10n.mapEventsValidationStart,
        CreateEventValidation.deadlineRequired =>
          l10n.mapEventsValidationDeadlineRequired,
        CreateEventValidation.coverRequired => l10n.mapEventsValidationCover,
        CreateEventValidation.endBeforeStart =>
          l10n.mapEventsValidationEndBeforeStart,
        CreateEventValidation.deadlineAfterStart =>
          l10n.mapEventsValidationDeadlineAfterStart,
        CreateEventValidation.capacityTooSmall =>
          l10n.mapEventsValidationCapacity,
        null => null,
        _ => l10n.mapEventsErrorInvalidInput,
      };
}

enum _LeaveChoice { keep, discard }

/// The post-submit confirmation. Every new event goes to the admin team, so
/// this is the honest end of the flow — not a jump to a page that isn't on the
/// map yet.
class _SubmittedView extends StatelessWidget {
  final CreateMapEventState state;

  const _SubmittedView({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kCreateEventMaxWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.hourglass_top_rounded,
                    size: 28,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.mapEventsPendingReviewTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.mapEventsPendingReviewBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.45,
                    color: AppColors.ink2,
                  ),
                ),
                if (state.coverUploadFailed) ...[
                  const SizedBox(height: 14),
                  _Warning(text: l10n.mapEventsCoverUploadFailed),
                ],
                if (state.contestsFailed > 0) ...[
                  const SizedBox(height: 10),
                  _Warning(
                    text: l10n.mapEventsContestsFailed(state.contestsFailed),
                    icon: Icons.emoji_events_outlined,
                  ),
                ],
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => context.pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kCreateEventRadius),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
                    ),
                    child: Text(l10n.mapEventsDone),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Something that didn't work but didn't stop the event existing.
class _Warning extends StatelessWidget {
  final String text;
  final IconData icon;

  const _Warning({
    required this.text,
    this.icon = Icons.image_not_supported_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(kCreateEventRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.mute),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.35,
                color: AppColors.ink2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  final CreateMapEventState state;

  const _LoadFailed({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final error = state.error ?? const MapEventError(MapEventErrorCode.generic);

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 32,
                color: AppColors.muteSoft,
              ),
              const SizedBox(height: 14),
              Text(
                mapEventErrorMessage(l10n, error),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.5, color: AppColors.ink2),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: () => context
                    .read<CreateMapEventBloc>()
                    .add(LoadCreateEventRefs(editEvent: state.editEvent)),
                style: TextButton.styleFrom(foregroundColor: AppColors.accent),
                child: Text(l10n.mapEventsRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
