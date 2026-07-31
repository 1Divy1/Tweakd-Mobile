import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/error/base_failures.dart';
import '../../domain/entities/tagged_item.dart';
import '../../domain/failures/tag_failures.dart';
import '../../domain/repositories/tags_repository.dart';
import '../datasources/tags_api_data_source.dart';
import '../models/tagged_item_models.dart';

@LazySingleton(as: TagsRepository)
class TagsRepositoryImpl implements TagsRepository {
  final TagsApiDataSource dataSource;

  TagsRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, TaggedItemPageEntity>> getMyTags({
    String? cursor,
    int size = 20,
  }) {
    return _page(() => dataSource.getMyTags(cursor: cursor, size: size));
  }

  @override
  Future<Either<Failure, TaggedItemPageEntity>> getTagsByUsername(
    String username, {
    String? cursor,
    int size = 20,
  }) {
    return _page(
      () => dataSource.getTagsByUsername(username, cursor: cursor, size: size),
    );
  }

  @override
  Future<Either<Failure, void>> removeTag(
    TaggedItemKind kind,
    String targetId,
  ) async {
    try {
      await dataSource.removeTag(kind, targetId);
      return const Right(null);
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      // 404 = the content itself is gone (an untag on a tag that isn't there
      // is a no-op 204, so it never lands here).
      if (e.statusCode == 404) return const Left(TaggedContentNotFoundFailure());
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('removeTag error: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  /// Both feed reads fail the same way, so the exception → failure mapping
  /// lives in one place.
  Future<Either<Failure, TaggedItemPageEntity>> _page(
    Future<TaggedItemPageModel> Function() fetch,
  ) async {
    try {
      final model = await fetch();
      return Right(model.toEntity());
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      // The only documented 400 on the feed reads is a malformed cursor.
      if (e.statusCode == 400) return const Left(InvalidTagCursorFailure());
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('getTags error: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }
}
