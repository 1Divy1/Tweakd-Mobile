import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/services/image_service.dart';
import '../../../domain/entities/post.dart';
import '../../../domain/entities/post_params.dart';
import '../../../domain/usecases/create_post.dart';
import '../../../domain/usecases/delete_post.dart';
import '../../../domain/usecases/get_image_upload_urls.dart';
import '../../../domain/usecases/save_image_keys.dart';
import '../../../domain/usecases/upload_post_image.dart';
import '../../utils/post_error_mapper.dart';
import 'event.dart';
import 'state.dart';

@injectable
class CreatePostBloc extends Bloc<CreatePostEvent, CreatePostState> {
  final CreatePostUseCase createPost;
  final GetImageUploadUrlsUseCase getImageUploadUrls;
  final UploadPostImageUseCase uploadImage;
  final SaveImageKeysUseCase saveImageKeys;
  final DeletePostUseCase deletePost;
  final ImageService imageService;

  CreatePostBloc({
    required this.createPost,
    required this.getImageUploadUrls,
    required this.uploadImage,
    required this.saveImageKeys,
    required this.deletePost,
    required this.imageService,
  }) : super(const CreatePostInitial()) {
    on<SubmitPost>(_onSubmit);
  }

  FutureOr<void> _onSubmit(
    SubmitPost event,
    Emitter<CreatePostState> emit,
  ) async {
    // ── Step 1: create the post (text only) ──────────────────────────────────
    emit(const CreatePostSubmitting(CreatePostPhase.creating));

    final createResult = await createPost(
      CreatePostParams(
        description: event.description,
        taggedPeople: event.taggedPeopleIds,
        taggedCars: event.taggedCarIds,
        likesCountEnabled: event.likesCountEnabled,
        commentsCountEnabled: event.commentsCountEnabled,
        sharesCountEnabled: event.sharesCountEnabled,
        savedCountEnabled: event.savedCountEnabled,
      ),
    );

    final post = createResult.fold<PostEntity?>(
      (failure) {
        emit(CreatePostError(PostErrorMapper.getCode(failure)));
        return null;
      },
      (post) => post,
    );
    if (post == null) return;

    // No images — the post is already complete.
    if (event.photoPaths.isEmpty) {
      emit(CreatePostSuccess(post));
      return;
    }

    // ── Step 2: upload images, then commit their keys in display order ────────
    // On any failure the just-created post is rolled back so the user isn't left
    // with an imageless post.
    emit(const CreatePostSubmitting(CreatePostPhase.uploadingImages));

    try {
      final keys = await _uploadImages(post.id, event.photoPaths);

      final saveResult =
          await saveImageKeys(SaveImageKeysParams(postId: post.id, keys: keys));
      final finalPost = saveResult.fold(
        (f) => throw Exception('$f'),
        (p) => p,
      );

      emit(CreatePostSuccess(finalPost));
    } catch (e) {
      debugPrint('Create post image phase failed: $e');
      await deletePost(DeletePostParams(postId: post.id));
      emit(const CreatePostError(PostErrorCode.imageUploadFailed));
    }
  }

  /// Mints presigned slots, compresses + uploads each photo in parallel, and
  /// returns the R2 keys in the same order as [photoPaths] (the display order).
  /// The slots come back in an arbitrary order, so each photo is paired with the
  /// slot at its own index.
  Future<List<String>> _uploadImages(
    String postId,
    List<String> photoPaths,
  ) async {
    final uploads = (await getImageUploadUrls(
      GetImageUploadUrlsParams(postId: postId, count: photoPaths.length),
    ))
        .fold((f) => throw Exception('$f'), (r) => r.uploads);

    if (uploads.length < photoPaths.length) {
      throw Exception('Insufficient upload slots.');
    }

    return Future.wait([
      for (var i = 0; i < photoPaths.length; i++)
        _uploadOne(photoPaths[i], uploads[i].uploadUrl, uploads[i].key),
    ]);
  }

  /// Compresses one photo to WebP, PUTs it to its presigned slot, and returns
  /// the slot's R2 key.
  Future<String> _uploadOne(String path, String uploadUrl, String key) async {
    final bytes = await imageService.compressToWebp(path);
    (await uploadImage(UploadPostImageParams(uploadUrl: uploadUrl, bytes: bytes)))
        .fold((f) => throw Exception('$f'), (_) {});
    return key;
  }
}
