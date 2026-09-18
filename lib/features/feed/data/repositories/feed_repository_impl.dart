import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/error/base_failures.dart';
import '../../domain/entities/feed_page.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_api_data_source.dart';
import '../datasources/feed_local_data_source.dart';
import '../models/feed_page_model.dart';

@LazySingleton(as: FeedRepository)
class FeedRepositoryImpl implements FeedRepository {
  final FeedApiDataSource dataSource;
  final FeedLocalDataSource localDataSource;

  FeedRepositoryImpl(this.dataSource, this.localDataSource);

  @override
  Future<Either<Failure, FeedPageEntity>> getGlobalFeed({
    String? cursor,
    int size = 20,
  }) async {
    try {
      if (cursor != null) {
        final model = await dataSource.getGlobalFeed(
          cursor: cursor,
          size: size,
        );
        return Right(model.toEntity());
      }

      // Every successful first page — launch, pull-to-refresh, after posting —
      // becomes the page the next cold start opens on. Saved in the background:
      // the caller shouldn't wait on a disk write to show what it already has.
      final json = await dataSource.getGlobalFeedJson(size: size);
      final model = FeedPageModel.fromJson(json);
      unawaited(localDataSource.write(json));
      return Right(model.toEntity());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('getGlobalFeed error: $e');
      return const Left(UnknownFailure('Failed to load the feed.'));
    }
  }

  @override
  Future<FeedPageEntity?> getCachedFirstPage() async {
    final json = await localDataSource.read();
    if (json == null) return null;
    try {
      return FeedPageModel.fromJson(json).toEntity();
    } catch (e) {
      // A cache the current model can no longer parse is simply no cache.
      debugPrint('Discarding unreadable feed cache: ${e.runtimeType}');
      unawaited(localDataSource.clear());
      return null;
    }
  }

  @override
  Future<void> clearCache() => localDataSource.clear();
}
