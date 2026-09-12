import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:tweakd/core/shared/entities/tag_selection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/create_post/bloc.dart';
import '../bloc/create_post/event.dart';
import '../bloc/create_post/state.dart';
import '../utils/post_error_mapper.dart';
import '../widgets/create_post/caption_step.dart';
import '../widgets/create_post/create_post_chrome.dart';
import '../widgets/create_post/create_post_fields.dart';
import '../widgets/create_post/photos_step.dart';
import '../widgets/create_post/post_discard_dialog.dart';
import '../widgets/create_post/post_photo.dart';
import '../widgets/create_post/review_step.dart';
import '../widgets/create_post/tags_step.dart';
import '../widgets/create_post/visibility_step.dart';

/// The five-step create-post wizard (photos → caption → tags → visibility →
/// review), in the same shape as onboarding, the add-car flow and the
/// create-event wizard: X and a slim progress bar on top, one step per screen,
/// BACK / NEXT flush at the bottom.
///
/// The form lives here rather than in the bloc — the bloc only publishes.
class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  int _step = 0;

  /// Every step shares one scroll view, so moving between them has to put the
  /// user back at the top of the new content.
  final _scroll = ScrollController();

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
    _scroll.dispose();
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
        final isLast = _step == postStepCount - 1;

        return Scaffold(
          backgroundColor: AppColors.bg,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Column(
              children: [
                PostTopBar(
                  step: _step,
                  onClose: isSubmitting ? null : () => _close(context),
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: kPostMaxWidth,
                      ),
                      child: ListView(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                        children: [_stepContent(l10n)],
                      ),
                    ),
                  ),
                ),
                PostBottomBar(
                  canGoBack: _step > 0,
                  isLastStep: isLast,
                  isSubmitting: isSubmitting,
                  backLabel: l10n.postBack,
                  nextLabel: switch (state) {
                    CreatePostSubmitting(:final phase) =>
                      _phaseLabel(l10n, phase),
                    _ when isLast => l10n.postPublish,
                    _ => l10n.postNext,
                  },
                  blocker: _blocker(l10n),
                  onBack: () => _goTo(_step - 1),
                  onNext: () => _onNext(context),
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

  Widget _stepContent(AppLocalizations l10n) {
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

  /// What the current step still needs before NEXT will move. Only the photos
  /// step has a requirement — everything after it is optional.
  String? _blocker(AppLocalizations l10n) =>
      _step == 0 && _photos.isEmpty ? l10n.postValPhotosRequired : null;

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

  /// Advances, or publishes on the last step. A step that isn't in order
  /// doesn't move — the bottom bar is already naming what's missing.
  void _onNext(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (_blocker(AppLocalizations.of(context)!) != null) return;

    if (_step < postStepCount - 1) {
      _goTo(_step + 1);
      return;
    }
    _publish(context);
  }

  void _goTo(int step) {
    if (step < 0 || step >= postStepCount) return;
    setState(() => _step = step);
    if (_scroll.hasClients) _scroll.jumpTo(0);
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

  bool get _hasContent =>
      _photos.isNotEmpty ||
      _captionCtrl.text.trim().isNotEmpty ||
      _people.isNotEmpty ||
      _cars.isNotEmpty;

  /// A blank composer closes straight away; one with something in it asks
  /// first, since nothing is kept once it's gone.
  Future<void> _close(BuildContext context) async {
    final navigator = Navigator.of(context);
    if (!_hasContent) {
      navigator.pop();
      return;
    }
    final discard = await showPostDiscardDialog(context);
    if (discard == true && navigator.canPop()) navigator.pop();
  }
}
