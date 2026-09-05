import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/error/base_failures.dart';
import '../../domain/entities/feed_page.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_api_data_source.dart';

@LazySingleton(as: FeedRepository)
class FeedRepositoryImpl implements FeedRepository {
  final FeedApiDataSource dataSource;

  FeedRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, FeedPageEntity>> getGlobalFeed({
    String? cursor,
    int size = 20,
  }) async {
    try {
      final model = await dataSource.getGlobalFeed(cursor: cursor, size: size);
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
}
