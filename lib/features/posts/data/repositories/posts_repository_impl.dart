import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/error/base_failures.dart';
import '../../../../core/services/image_service.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/post_comment.dart';
import '../../domain/entities/post_params.dart';
import '../../domain/entities/post_pages.dart';
import '../../domain/entities/post_upload.dart';
import '../../domain/failures/post_failures.dart';
import '../../domain/repositories/posts_repository.dart';
import '../datasources/posts_api_data_source.dart';
import '../datasources/posts_storage_api_data_source.dart';

@LazySingleton(as: PostsRepository)
class PostsRepositoryImpl implements PostsRepository {
  final PostsApiDataSource dataSource;
  final PostsStorageApiDataSource storageDataSource;
  final ImageService imageService;

  PostsRepositoryImpl(
    this.dataSource,
    this.storageDataSource,
    this.imageService,
  );

  // ── Create + images ────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, PostEntity>> createPost(
      CreatePostParams params) async {
    try {
      final model = await dataSource.createPost(params.toJson());
      return Right(model.toEntity());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 400) return Left(InvalidTagFailure(e.message));
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('createPost error: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> shareParticipantCard(
      ShareParticipantCardParams params) async {
    try {
      final model = await dataSource.shareParticipantCard(params.toJson());
      return Right(model.toEntity());
    } on ConflictException catch (e) {
      // The cooldown says exactly when the card may go out again.
      final next = DateTime.tryParse(
        e.details?['next_post_allowed_at'] as String? ?? '',
      )?.toLocal();
      if (e.errorCode == 'participant_card_cooldown' && next != null) {
        return Left(ParticipantCardCooldownFailure(next));
      }
      return Left(ServerFailure(e.message));
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('shareParticipantCard error: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, PostUploadUrlsResult>> getImageUploadUrls(
    String postId,
    int count,
  ) async {
    try {
      final model =
          await storageDataSource.getImageUploadUrls(postId, count);
      return Right(model.toEntity());
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('getImageUploadUrls error: $e');
      return const Left(UnknownFailure('Failed to get upload URLs.'));
    }
  }

  @override
  Future<Either<Failure, void>> uploadImageToR2(
    String uploadUrl,
    Uint8List bytes,
  ) async {
    try {
      await imageService.uploadToR2(uploadUrl, bytes);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('uploadImageToR2 error: $e');
      return const Left(UnknownFailure('Upload failed.'));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> saveImageKeys(
    String postId,
    List<String> keys,
  ) async {
    try {
      final model = await dataSource.saveImageKeys(postId, keys);
      return Right(model.toEntity());
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 403) return const Left(NotPostOwnerFailure());
      if (e.statusCode == 404) return const Left(PostNotFoundFailure());
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('saveImageKeys error: $e');
      return const Left(UnknownFailure('Failed to save images.'));
    }
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, PostEntity>> getPost(String postId) async {
    try {
      final model = await dataSource.getPost(postId);
      return Right(model.toEntity());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 404) return const Left(PostNotFoundFailure());
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('getPost error: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, PostPageEntity>> getMyPosts({
    String? cursor,
    int size = 20,
  }) async {
    try {
      final model = await dataSource.getMyPosts(cursor: cursor, size: size);
      return Right(model.toEntity());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('getMyPosts error: $e');
      return const Left(UnknownFailure('Failed to load posts.'));
    }
  }

  @override
  Future<Either<Failure, PostPageEntity>> getPostsByUsername(
    String username, {
    String? cursor,
    int size = 20,
  }) async {
    try {
      final model = await dataSource.getPostsByUsername(
        username,
        cursor: cursor,
        size: size,
      );
      return Right(model.toEntity());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 404) return const Left(PostNotFoundFailure());
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('getPostsByUsername error: $e');
      return const Left(UnknownFailure('Failed to load posts.'));
    }
  }

  @override
  Future<Either<Failure, PostPageEntity>> getSavedPosts({
    String? cursor,
    int size = 20,
  }) async {
    try {
      final model =
          await dataSource.getSavedPosts(cursor: cursor, size: size);
      return Right(model.toEntity());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('getSavedPosts error: $e');
      return const Left(UnknownFailure('Failed to load saved posts.'));
    }
  }

  @override
  Future<Either<Failure, CommentPageEntity>> getComments(
    String postId, {
    String? cursor,
    int size = 20,
  }) async {
    try {
      final model =
          await dataSource.getComments(postId, cursor: cursor, size: size);
      return Right(model.toEntity());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 404) return const Left(PostNotFoundFailure());
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('getComments error: $e');
      return const Left(UnknownFailure('Failed to load comments.'));
    }
  }

  @override
  Future<Either<Failure, LikerPageEntity>> getLikers(
    String postId, {
    String? cursor,
    int size = 20,
  }) async {
    try {
      final model =
          await dataSource.getLikers(postId, cursor: cursor, size: size);
      return Right(model.toEntity());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 404) return const Left(PostNotFoundFailure());
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('getLikers error: $e');
      return const Left(UnknownFailure('Failed to load likers.'));
    }
  }

  // ── Mutate ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, PostEntity>> updatePost(
    String postId,
    UpdatePostParams params,
  ) async {
    try {
      final model = await dataSource.updatePost(postId, params.toJson());
      return Right(model.toEntity());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 400) return Left(InvalidTagFailure(e.message));
      if (e.statusCode == 403) return const Left(NotPostOwnerFailure());
      if (e.statusCode == 404) return const Left(PostNotFoundFailure());
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('updatePost error: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePost(String postId) async {
    try {
      await dataSource.deletePost(postId);
      return const Right(null);
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 403) return const Left(NotPostOwnerFailure());
      if (e.statusCode == 404) return const Left(PostNotFoundFailure());
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('deletePost error: $e');
      return const Left(UnknownFailure('Failed to delete post.'));
    }
  }

  // ── Engagement ───────────────────────────────────────────────────────────────

  /// Shared wrapper for the body-less, idempotent engagement calls. They share
  /// one error shape: 404 → post/comment not found, everything else generic.
  Future<Either<Failure, void>> _engage(
    Future<void> Function() call,
    String label,
  ) async {
    try {
      await call();
      return const Right(null);
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 404) return const Left(PostNotFoundFailure());
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('$label error: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, void>> likePost(String postId) =>
      _engage(() => dataSource.likePost(postId), 'likePost');

  @override
  Future<Either<Failure, void>> unlikePost(String postId) =>
      _engage(() => dataSource.unlikePost(postId), 'unlikePost');

  @override
  Future<Either<Failure, void>> savePost(String postId) =>
      _engage(() => dataSource.savePost(postId), 'savePost');

  @override
  Future<Either<Failure, void>> unsavePost(String postId) =>
      _engage(() => dataSource.unsavePost(postId), 'unsavePost');

  @override
  Future<Either<Failure, void>> sharePost(String postId, {String? content}) =>
      _engage(() => dataSource.sharePost(postId, content: content), 'sharePost');

  @override
  Future<Either<Failure, void>> unsharePost(String postId) =>
      _engage(() => dataSource.unsharePost(postId), 'unsharePost');

  // ── Comments ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, PostCommentEntity>> addComment(
    String postId, {
    required String content,
    String? parentCommentId,
    List<String> taggedPeople = const [],
    List<String> taggedCars = const [],
  }) async {
    try {
      final model = await dataSource.addComment(
        postId,
        content: content,
        parentCommentId: parentCommentId,
        taggedPeople: taggedPeople,
        taggedCars: taggedCars,
      );
      return Right(model.toEntity());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 404) return const Left(PostNotFoundFailure());
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('addComment error: $e');
      return const Left(UnknownFailure('Failed to add comment.'));
    }
  }

  @override
  Future<Either<Failure, CommentPageEntity>> getReplies(
    String postId,
    String commentId, {
    String? cursor,
    int size = 20,
  }) async {
    try {
      final model = await dataSource.getReplies(
        postId,
        commentId,
        cursor: cursor,
        size: size,
      );
      return Right(model.toEntity());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 404) return const Left(PostNotFoundFailure());
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('getReplies error: $e');
      return const Left(UnknownFailure('Failed to load replies.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment(
    String postId,
    String commentId,
  ) async {
    try {
      await dataSource.deleteComment(postId, commentId);
      return const Right(null);
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 403) return const Left(NotPostOwnerFailure());
      if (e.statusCode == 404) return const Left(PostNotFoundFailure());
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('deleteComment error: $e');
      return const Left(UnknownFailure('Failed to delete comment.'));
    }
  }

  @override
  Future<Either<Failure, void>> likeComment(String postId, String commentId) =>
      _engage(() => dataSource.likeComment(postId, commentId), 'likeComment');

  @override
  Future<Either<Failure, void>> unlikeComment(
    String postId,
    String commentId,
  ) =>
      _engage(
          () => dataSource.unlikeComment(postId, commentId), 'unlikeComment');
}
