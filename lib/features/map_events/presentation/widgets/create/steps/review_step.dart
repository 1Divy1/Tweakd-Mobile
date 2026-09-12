import 'dart:io';

import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../bloc/create_event/state.dart';
import '../../../utils/map_event_formatting.dart';
import '../create_event_chrome.dart';
import '../create_event_fields.dart';

/// Step 7 — the event as people will see it, with a way back into every step
/// that produced it.
///
/// It's a preview built from form state rather than the real detail page: the
/// event doesn't exist yet, and every widget on that page is shaped around a
/// `MapEventEntity` with an id, counts and a viewer state that only the server
/// can produce.
class ReviewStep extends StatelessWidget {
  final CreateMapEventState state;

  /// Jumps the wizard back to a step. Every section header carries one.
  final ValueChanged<CreateEventStep> onEdit;

  const ReviewStep({super.key, required this.state, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateEventStepHeader(
          title: l10n.mapEventsStepReviewTitle,
          subtitle: l10n.mapEventsStepReviewSubtitle,
        ),
        _CoverPreview(state: state, onEdit: () => onEdit(CreateEventStep.cover)),
        const SizedBox(height: 18),
        _Section(
          label: l10n.mapEventsFieldTitle,
          onEdit: () => onEdit(CreateEventStep.basics),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.title.trim(),
                style: TextStyle(
                  fontSize: 20,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.description.trim().isEmpty
                    ? l10n.mapEventsReviewNoDescription
                    : state.description.trim(),
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: state.description.trim().isEmpty
                      ? AppColors.muteSoft
                      : AppColors.ink2,
                ),
              ),
            ],
          ),
        ),
        _Section(
          label: l10n.mapEventsReviewSectionSchedule,
          onEdit: () => onEdit(CreateEventStep.whenWhere),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Row(
                icon: Icons.event_rounded,
                text: state.startsAt == null
                    ? '—'
                    : MapEventFormat.deadline(context, state.startsAt!),
              ),
              _Row(
                icon: Icons.schedule_rounded,
                text: state.endsAt == null
                    ? l10n.mapEventsReviewOpenEnded
                    : MapEventFormat.deadline(context, state.endsAt!),
              ),
              if (state.registrationDeadline != null)
                _Row(
                  icon: Icons.how_to_reg_rounded,
                  text: '${l10n.mapEventsFieldDeadline}: '
                      '${MapEventFormat.deadline(context, state.registrationDeadline!)}',
                ),
              _Row(
                icon: Icons.place_rounded,
                text: state.locationName.trim().isEmpty
                    ? '—'
                    : state.locationName.trim(),
              ),
            ],
          ),
        ),
        _Section(
          label: l10n.mapEventsReviewSectionOrganizers,
          onEdit: () => onEdit(CreateEventStep.organizers),
          child: state.pendingOrganizers.isEmpty &&
                  (state.editEvent?.organizers.isEmpty ?? true)
              ? EventHint(l10n.mapEventsReviewNoOrganizers)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final organizer
                        in state.editEvent?.organizers ?? const [])
                      _Row(
                        icon: organizer.isBusiness
                            ? Icons.storefront_rounded
                            : Icons.person_rounded,
                        text: organizer.name,
                      ),
                    for (final pending in state.pendingOrganizers)
                      _Row(
                        icon: pending.candidate.isBusiness
                            ? Icons.storefront_rounded
                            : Icons.person_rounded,
                        text: pending.candidate.name,
                      ),
                  ],
                ),
        ),
        _Section(
          label: l10n.mapEventsReviewSectionEntry,
          onEdit: () => onEdit(CreateEventStep.rules),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Row(
                icon: Icons.verified_user_outlined,
                text: state.requiresApproval
                    ? l10n.mapEventsReviewApprovalOn
                    : l10n.mapEventsReviewApprovalOff,
              ),
              _Row(
                icon: Icons.groups_rounded,
                text: state.capacity == null
                    ? l10n.mapEventsCapacityUnlimited
                    : '${state.capacity}',
              ),
              const SizedBox(height: 6),
              if (_cleanRules.isEmpty)
                EventHint(l10n.mapEventsReviewNoRules)
              else
                for (var i = 0; i < _cleanRules.length; i++)
                  _Bullet(index: i + 1, text: _cleanRules[i]),
            ],
          ),
        ),
        // Editing an event never runs the CONTESTS step, so it has nothing to
        // preview here either.
        if (!state.isEditing)
          _Section(
            label: l10n.mapEventsStepContestsTitle,
            onEdit: () => onEdit(CreateEventStep.contests),
            child: state.pendingContests.isEmpty
                ? EventHint(l10n.mapEventsReviewNoContests)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final contest in state.pendingContests)
                        _Row(
                          icon: Icons.emoji_events_rounded,
                          text: contest.title,
                        ),
                    ],
                  ),
          ),
      ],
    );
  }

  /// Blank rows are dropped before submit, so the preview shouldn't count them.
  List<String> get _cleanRules => [
        for (final rule in state.rules)
          if (rule.trim().isNotEmpty) rule.trim(),
      ];
}

class _CoverPreview extends StatelessWidget {
  final CreateMapEventState state;
  final VoidCallback onEdit;

  const _CoverPreview({required this.state, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final picked = state.cover;
    final existing = state.existingCoverUrl;

    if (picked == null && existing == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onEdit,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kCreateEventRadius),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: SizedBox(
            width: double.infinity,
            child: picked != null
                ? Image.file(File(picked.path), fit: BoxFit.cover)
                : Image.network(existing!, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

/// One reviewable block: an uppercase label, an EDIT affordance that jumps back
/// to the step that owns it, and the block's content.
class _Section extends StatelessWidget {
  final String label;
  final VoidCallback onEdit;
  final Widget child;

  const _Section({
    required this.label,
    required this.onEdit,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(kCreateEventRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: AppColors.mute,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  child: Text(l10n.mapEventsReviewEdit),
                ),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Row({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 15, color: AppColors.mute),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.5,
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

class _Bullet extends StatelessWidget {
  final int index;
  final String text;

  const _Bullet({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '$index.',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: AppColors.mute,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.5,
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
