import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/error/base_failures.dart';
import '../../../../core/services/image_service.dart';
import '../../domain/entities/post.dart';
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
}
