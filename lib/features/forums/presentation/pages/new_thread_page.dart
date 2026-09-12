import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/composer/bloc.dart';
import '../bloc/composer/event.dart';
import '../bloc/composer/state.dart';
import '../utils/forum_error_mapper.dart';
import '../widgets/composer/thread_category_picker.dart';
import '../widgets/composer/topic_selector.dart';
import '../widgets/shared/forum_error_view.dart';
import '../widgets/shared/forum_sub_top_bar.dart';
import 'package:tweakd/core/shared/widgets/tagging/tag_editor.dart';

class NewThreadPage extends StatefulWidget {
  const NewThreadPage({super.key});

  @override
  State<NewThreadPage> createState() => _NewThreadPageState();
}

class _NewThreadPageState extends State<NewThreadPage> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _peopleSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // The Post button enables with a non-empty title and body.
    _titleController.addListener(() => setState(() {}));
    _bodyController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _peopleSearchController.dispose();
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
                  SnackBar(content: Text(l10n.forumsThreadPosted)),
                );
              context.pushReplacement(
                '/forums/threads/${state.createdThreadId}',
              );
              return;
            }
            if (state.actionError != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(forumErrorMessage(l10n, state.actionError!)),
                  ),
                );
            }
          },
          builder: (context, state) {
            // A title, a body and a brand are required; the model is optional.
            final canPost =
                _titleController.text.trim().isNotEmpty &&
                _bodyController.text.trim().isNotEmpty &&
                state.hasBrand &&
                !state.isSubmitting;

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
                    (true, _) => Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                    (false, final code?) => ForumErrorView(
                      message: forumErrorMessage(l10n, code),
                      onRetry: () => context.read<NewThreadBloc>().add(
                        const LoadNewThreadRefs(),
                      ),
                    ),
                    _ => _ComposerForm(
                      state: state,
                      titleController: _titleController,
                      bodyController: _bodyController,
                      peopleSearchController: _peopleSearchController,
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
  final TextEditingController peopleSearchController;

  const _ComposerForm({
    required this.state,
    required this.titleController,
    required this.bodyController,
    required this.peopleSearchController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<NewThreadBloc>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        _ComposerField(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: titleController,
            maxLength: 200,
            maxLines: null,
            cursorColor: AppColors.accent,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              counterText: '',
              hintText: l10n.forumsThreadTitleHint,
              hintStyle: TextStyle(
                color: AppColors.muteSoft,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _ComposerField(
          child: TextField(
            controller: bodyController,
            minLines: 5,
            maxLines: null,
            maxLength: 20000,
            cursorColor: AppColors.accent,
            style: TextStyle(
              color: AppColors.ink2,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              counterText: '',
              hintText: l10n.forumsThreadBodyHint,
              hintStyle: TextStyle(
                color: AppColors.muteSoft,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ThreadCategoryPicker(
          state: state,
          onSelectBrand: (brand) => bloc.add(SelectNewThreadBrand(brand)),
          onClearBrand: () => bloc.add(const ClearNewThreadBrand()),
          onSelectModel: (model) => bloc.add(SelectNewThreadModel(model)),
          onClearModel: () => bloc.add(const ClearNewThreadModel()),
        ),
        const SizedBox(height: 24),
        TagEditor(
          people: state.taggedPeople,
          cars: state.taggedCars,
          peopleSearchController: peopleSearchController,
          onAddPerson: (person) => bloc.add(AddNewThreadTagPerson(person)),
          onRemovePerson: (id) => bloc.add(RemoveNewThreadTagPerson(id)),
          onAddCar: (car) => bloc.add(AddNewThreadTagCar(car)),
          onRemoveCar: (id) => bloc.add(RemoveNewThreadTagCar(id)),
        ),
        const SizedBox(height: 24),
        TopicSelector(
          topics: state.topics,
          selectedTopicIds: state.selectedTopicIds,
          onToggle: (id) => bloc.add(ToggleNewThreadTopic(id)),
        ),
      ],
    );
  }
}

/// Rounded card the title and body fields sit in, matching the rest of the
/// composer's inputs.
class _ComposerField extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _ComposerField({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
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
          borderRadius: BorderRadius.circular(18),
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
