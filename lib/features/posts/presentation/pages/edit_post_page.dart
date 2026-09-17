import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:tweakd/core/shared/entities/tag_selection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/post.dart';
import '../bloc/edit_post/bloc.dart';
import '../utils/post_error_mapper.dart';
import '../widgets/create_post/caption_step.dart';
import '../widgets/create_post/post_discard_dialog.dart';
import '../widgets/create_post/tags_step.dart';
import '../widgets/create_post/visibility_step.dart';
import '../../../../core/shared/layout/app_layout.dart';

/// What an [EditPostPage] returns to the detail screen: the updated post, or a
/// flag that it was deleted. Null is returned when the user just backs out.
class PostEditResult {
  final PostEntity? updated;
  final bool deleted;

  const PostEditResult({this.updated, this.deleted = false});
}

/// Edits an existing post's description, tags and counter visibility — images
/// are immutable after publish — with an option to delete the post.
class EditPostPage extends StatefulWidget {
  final PostEntity post;

  const EditPostPage({super.key, required this.post});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late final TextEditingController _captionCtrl;
  final _peopleSearchCtrl = TextEditingController();
  late final List<TaggedPerson> _people;
  late final List<TaggedCar> _cars;
  late PostVisibility _visibility;

  /// The post as it opened, so closing only asks when an edit would be lost.
  late final List<Object?> _baseline;

  List<Object?> get _snapshot => [
        _captionCtrl.text.trim(),
        '|', ..._people.map((p) => p.id),
        '|', ..._cars.map((c) => c.id),
        _visibility.showLikes,
        _visibility.showComments,
        _visibility.showShares,
        _visibility.showSaved,
      ];

  @override
  void initState() {
    super.initState();
    final post = widget.post;
    _captionCtrl = TextEditingController(text: post.description ?? '');
    _people = post.taggedPeople
        .map((p) => TaggedPerson(
              id: p.id,
              username: p.username,
              avatarUrl: p.avatarUrl,
            ))
        .toList();
    // Existing tagged cars carry their owner (CarOwnerDto) on the wire, so an
    // untagged owner auto-removes their cars just like newly picked ones do.
    _cars = post.taggedCars
        .map((c) => TaggedCar(
              id: c.id,
              name: '${c.make} ${c.model}'.trim(),
              ownerId: c.ownerId ?? '',
              ownerHandle: c.ownerUsername ?? '',
            ))
        .toList();
    _visibility = PostVisibility(
      showLikes: post.likesCountEnabled,
      showComments: post.commentsCountEnabled,
      showShares: post.sharesCountEnabled,
      showSaved: post.savedCountEnabled,
    );
    _baseline = _snapshot;
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    _peopleSearchCtrl.dispose();
    super.dispose();
  }

  void _removePerson(int index) {
    setState(() {
      final removed = _people.removeAt(index);
      _cars.removeWhere((c) => c.ownerId == removed.id);
    });
  }

  void _save() {
    final description = _captionCtrl.text.trim();
    context.read<EditPostBloc>().add(
          SubmitPostEdit(
            postId: widget.post.id,
            description: description,
            taggedPeople: _people.map((p) => p.id).toList(),
            taggedCars: _cars.map((c) => c.id).toList(),
            likesCountEnabled: _visibility.showLikes,
            commentsCountEnabled: _visibility.showComments,
            sharesCountEnabled: _visibility.showShares,
            savedCountEnabled: _visibility.showSaved,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocConsumer<EditPostBloc, EditPostState>(
      listener: (context, state) {
        if (state is EditPostSuccess) {
          context.pop(PostEditResult(updated: state.post));
        }
        if (state is EditPostDeleted) {
          context.pop(const PostEditResult(deleted: true));
        }
        if (state is EditPostError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(postErrorMessage(l10n, state.code))),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state is EditPostSubmitting;
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && !isSubmitting) _close();
          },
          child: Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Column(
              children: [
                _TopBar(
                  isSubmitting: isSubmitting,
                  onClose: isSubmitting ? null : _close,
                  onSave: isSubmitting ? null : _save,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32) +
          AppLayout.inset(context, maxWidth: AppLayout.formWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CaptionStep(controller: _captionCtrl),
                        const SizedBox(height: 32),
                        TagsStep(
                          people: _people,
                          cars: _cars,
                          peopleSearchCtrl: _peopleSearchCtrl,
                          onAddPerson: (p) => setState(() => _people.add(p)),
                          onRemovePerson: _removePerson,
                          onAddCar: (c) => setState(() => _cars.add(c)),
                          onRemoveCar: (i) =>
                              setState(() => _cars.removeAt(i)),
                        ),
                        const SizedBox(height: 32),
                        VisibilityStep(
                          visibility: _visibility,
                          onChanged: (v) => setState(() => _visibility = v),
                        ),
                        const SizedBox(height: 28),
                        _DeleteButton(
                          enabled: !isSubmitting,
                          onTap: () => _confirmDelete(context),
                          label: l10n.postDeleteAction,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        );
      },
    );
  }

  Future<void> _close() async {
    final navigator = Navigator.of(context);
    if (listEquals(_baseline, _snapshot)) {
      navigator.pop();
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final discard = await showPostDiscardDialog(
      context,
      title: l10n.postEditDiscardTitle,
      body: l10n.postEditDiscardBody,
    );
    if (discard == true) navigator.pop();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<EditPostBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.postDeleteTitle,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.postDeleteBody,
                style: TextStyle(
                  color: AppColors.mute,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _DialogButton(
                      label: l10n.garageDialogCancel,
                      onTap: () => Navigator.of(dialogContext).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DialogButton(
                      label: l10n.garageDialogDelete,
                      isDestructive: true,
                      onTap: () => Navigator.of(dialogContext).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true) bloc.add(SubmitPostDelete(widget.post.id));
  }
}

class _TopBar extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback? onClose;
  final VoidCallback? onSave;

  const _TopBar({
    required this.isSubmitting,
    this.onClose,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8) + AppLayout.inset(context),
      child: Row(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 44,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.line),
              ),
              child: Icon(Icons.close_rounded,
                  color: AppColors.ink, size: 20),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                l10n.postEditTitle,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onSave,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: isSubmitting ? AppColors.muteSoft : AppColors.accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      l10n.postEditSave,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  final String label;

  const _DeleteButton({
    required this.enabled,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.danger.withAlpha(120)),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.danger,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DialogButton({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDestructive ? AppColors.danger : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDestructive ? AppColors.danger : AppColors.line),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isDestructive ? AppColors.onDanger : AppColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
