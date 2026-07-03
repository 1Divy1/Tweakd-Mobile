import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/composer/bloc.dart';
import '../bloc/composer/event.dart';
import '../bloc/composer/state.dart';
import '../utils/forum_error_mapper.dart';
import '../widgets/composer/car_tag_picker.dart';
import '../widgets/composer/topic_selector.dart';
import '../widgets/shared/forum_error_view.dart';
import '../widgets/shared/forum_sub_top_bar.dart';

class NewThreadPage extends StatefulWidget {
  const NewThreadPage({super.key});

  @override
  State<NewThreadPage> createState() => _NewThreadPageState();
}

class _NewThreadPageState extends State<NewThreadPage> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _carSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // The Post button enables with a non-empty title.
    _titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _carSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: BlocConsumer<NewThreadBloc, NewThreadState>(
          listenWhen: (prev, curr) =>
              (curr.createdThreadId != null &&
                  prev.createdThreadId != curr.createdThreadId) ||
              (curr.actionError != null &&
                  prev.actionErrorTick != curr.actionErrorTick),
          listener: (context, state) {
            if (state.createdThreadId != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                    SnackBar(content: Text(l10n.forumsThreadPosted)));
              context.pushReplacement(
                '/forums/threads/${state.createdThreadId}',
              );
              return;
            }
            if (state.actionError != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: Text(forumErrorMessage(l10n, state.actionError!)),
                ));
            }
          },
          builder: (context, state) {
            final canPost =
                _titleController.text.trim().isNotEmpty && !state.isSubmitting;

            return Column(
              children: [
                ForumSubTopBar(
                  title: l10n.forumsNewThreadTitle,
                  trailing: _PostButton(
                    label: l10n.forumsPost,
                    enabled: canPost,
                    submitting: state.isSubmitting,
                    onTap: () => context.read<NewThreadBloc>().add(
                          SubmitNewThread(
                            title: _titleController.text,
                            content: _bodyController.text,
                          ),
                        ),
                  ),
                ),
                Expanded(
                  child: switch ((state.isLoadingRefs, state.refsError)) {
                    (true, _) => const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.accent),
                      ),
                    (false, final code?) => ForumErrorView(
                        message: forumErrorMessage(l10n, code),
                        onRetry: () => context
                            .read<NewThreadBloc>()
                            .add(const LoadNewThreadRefs()),
                      ),
                    _ => _ComposerForm(
                        state: state,
                        titleController: _titleController,
                        bodyController: _bodyController,
                        carSearchController: _carSearchController,
                      ),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ComposerForm extends StatelessWidget {
  final NewThreadState state;
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final TextEditingController carSearchController;

  const _ComposerForm({
    required this.state,
    required this.titleController,
    required this.bodyController,
    required this.carSearchController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<NewThreadBloc>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        TextField(
          controller: titleController,
          maxLength: 200,
          maxLines: null,
          cursorColor: AppColors.accent,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            counterText: '',
            hintText: l10n.forumsThreadTitleHint,
            hintStyle: const TextStyle(
              color: AppColors.muteSoft,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const Divider(color: AppColors.line, height: 1),
        const SizedBox(height: 8),
        TextField(
          controller: bodyController,
          minLines: 3,
          maxLines: null,
          maxLength: 20000,
          cursorColor: AppColors.accent,
          style: const TextStyle(
            color: AppColors.ink2,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            counterText: '',
            hintText: l10n.forumsThreadBodyHint,
            hintStyle: const TextStyle(
              color: AppColors.muteSoft,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 20),
        CarTagPicker(
          state: state,
          searchController: carSearchController,
          onQueryChanged: (q) => bloc.add(NewThreadCarQueryChanged(q)),
          onSelect: (option) {
            carSearchController.clear();
            bloc.add(SelectNewThreadCar(option));
          },
          onSelectGarageCar: (car) => bloc.add(SelectGarageCar(car)),
          onClear: () => bloc.add(const ClearNewThreadCar()),
        ),
        const SizedBox(height: 24),
        TopicSelector(
          topicGroups: state.topicGroups,
          selectedTopicIds: state.selectedTopicIds,
          onToggle: (id) => bloc.add(ToggleNewThreadTopic(id)),
        ),
      ],
    );
  }
}

class _PostButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool submitting;
  final VoidCallback onTap;

  const _PostButton({
    required this.label,
    required this.enabled,
    required this.submitting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: enabled ? AppColors.accent : AppColors.line,
          borderRadius: BorderRadius.circular(999),
        ),
        child: submitting
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  color: enabled ? Colors.white : AppColors.muteSoft,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}
