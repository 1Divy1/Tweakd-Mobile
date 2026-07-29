import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:car_social_media_app/core/shared/entities/tag_selection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/create_post/bloc.dart';
import '../bloc/create_post/event.dart';
import '../bloc/create_post/state.dart';
import '../utils/post_error_mapper.dart';
import '../widgets/create_post/caption_step.dart';
import '../widgets/create_post/create_post_chrome.dart';
import '../widgets/create_post/photos_step.dart';
import '../widgets/create_post/post_photo.dart';
import '../widgets/create_post/review_step.dart';
import '../widgets/create_post/tags_step.dart';
import '../widgets/create_post/visibility_step.dart';

/// The five-step create-post wizard (photos → caption → tags → visibility →
/// review). UI-only for now: state is held locally and publishing is wired once
/// the backend contract lands.
class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  int _step = 0;

  // Guards against a second image_picker request firing before the first
  // finishes — iOS throws PlatformException('multiple_request') otherwise.
  bool _isPicking = false;

  // Step 1 — Photos
  final List<PostPhoto> _photos = [];

  // Step 2 — Caption
  final _captionCtrl = TextEditingController();

  // Step 3 — Tags
  final List<TaggedCar> _cars = [];
  final List<TaggedPerson> _people = [];
  final _peopleSearchCtrl = TextEditingController();

  // Step 4 — Visibility
  PostVisibility _visibility = const PostVisibility();

  @override
  void dispose() {
    _captionCtrl.dispose();
    _peopleSearchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocConsumer<CreatePostBloc, CreatePostState>(
      listener: (context, state) {
        if (state is CreatePostSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.postCreatedSuccess)),
          );
          context.pop();
        }
        if (state is CreatePostError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(postErrorMessage(l10n, state.code))),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state is CreatePostSubmitting;
        final submitLabel = state is CreatePostSubmitting
            ? _phaseLabel(l10n, state.phase)
            : null;

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Column(
              children: [
                PostTopBar(
                  step: _step,
                  onClose:
                      isSubmitting ? () {} : () => _confirmClose(context),
                ),
                PostStepProgress(step: _step),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    child: _stepContent(),
                  ),
                ),
                PostBottomBar(
                  step: _step,
                  isSubmitting: isSubmitting,
                  submitLabel: submitLabel,
                  onBack: _step > 0 && !isSubmitting
                      ? () => setState(() => _step--)
                      : null,
                  onNext: isSubmitting ? null : () => _onNext(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _phaseLabel(AppLocalizations l10n, CreatePostPhase phase) =>
      switch (phase) {
        CreatePostPhase.creating => l10n.postPhaseCreating,
        CreatePostPhase.uploadingImages => l10n.postPhaseUploading,
      };

  Widget _stepContent() {
    final l10n = AppLocalizations.of(context)!;
    return switch (_step) {
      0 => PhotosStep(
          photos: _photos,
          onAdd: _pickPhotos,
          onRemove: (i) => setState(() => _photos.removeAt(i)),
          onReorder: _reorderPhotos,
        ),
      1 => CaptionStep(controller: _captionCtrl),
      2 => TagsStep(
          people: _people,
          cars: _cars,
          peopleSearchCtrl: _peopleSearchCtrl,
          onAddPerson: (person) => setState(() => _people.add(person)),
          onRemovePerson: _removePerson,
          onAddCar: (car) => setState(() => _cars.add(car)),
          onRemoveCar: (i) => setState(() => _cars.removeAt(i)),
        ),
      3 => VisibilityStep(
          visibility: _visibility,
          onChanged: (v) => setState(() => _visibility = v),
        ),
      4 => ReviewStep(
          photos: _photos,
          caption: _captionCtrl.text,
          visibility: _visibility,
          authorName: l10n.postReviewYou,
        ),
      _ => const SizedBox.shrink(),
    };
  }

  Future<void> _pickPhotos() async {
    if (_isPicking) return;
    _isPicking = true;
    try {
      final remaining = postMaxPhotos - _photos.length;
      if (remaining <= 0) return;
      final picker = ImagePicker();
      final files = await picker.pickMultiImage(limit: remaining);
      if (files.isEmpty || !mounted) return;
      setState(() => _photos.addAll(
            files.take(remaining).map((f) => LocalPostPhoto(f.path)),
          ));
    } on PlatformException {
      // A pick was already in progress (e.g. a double tap) — safe to ignore.
    } finally {
      _isPicking = false;
    }
  }

  void _reorderPhotos(int oldIndex, int newIndex) {
    setState(() {
      final moved = _photos.removeAt(oldIndex);
      _photos.insert(newIndex, moved);
    });
  }

  /// Removes a tagged person and, with them, any of their cars that were tagged
  /// — the backend rejects a car whose owner isn't also tagged.
  void _removePerson(int index) {
    setState(() {
      final removed = _people.removeAt(index);
      _cars.removeWhere((c) => c.ownerId == removed.id);
    });
  }

  void _onNext(BuildContext context) {
    if (_step < postStepCount - 1) {
      if (!_validateStep(context)) return;
      setState(() => _step++);
      return;
    }
    _publish(context);
  }

  bool _validateStep(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_step == 0 && _photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.postValPhotosRequired)),
      );
      return false;
    }
    return true;
  }

  void _publish(BuildContext context) {
    final description = _captionCtrl.text.trim();
    context.read<CreatePostBloc>().add(
          SubmitPost(
            description: description.isEmpty ? null : description,
            photoPaths: _photos
                .whereType<LocalPostPhoto>()
                .map((p) => p.path)
                .toList(),
            taggedPeopleIds: _people.map((p) => p.id).toList(),
            taggedCarIds: _cars.map((c) => c.id).toList(),
            likesCountEnabled: _visibility.showLikes,
            commentsCountEnabled: _visibility.showComments,
            sharesCountEnabled: _visibility.showShares,
            savedCountEnabled: _visibility.showSaved,
          ),
        );
  }

  Future<void> _confirmClose(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);
    final discard = await showDialog<bool>(
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
                l10n.postDiscardTitle,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.postDiscardBody,
                style: const TextStyle(
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
                    child: _CloseDialogButton(
                      label: l10n.postKeepEditing,
                      onTap: () => Navigator.of(dialogContext).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CloseDialogButton(
                      label: l10n.postDiscard,
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

    if (discard == true && navigator.canPop()) navigator.pop();
  }
}

/// Pill button used in the "discard post" confirmation dialog.
class _CloseDialogButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _CloseDialogButton({
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
          color: isDestructive ? Colors.red : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive ? Colors.red : AppColors.line,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isDestructive ? Colors.white : AppColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
