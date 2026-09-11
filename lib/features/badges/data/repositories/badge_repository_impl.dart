import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/error/base_failures.dart';
import '../../domain/entities/user_badge.dart';
import '../../domain/repositories/badge_repository.dart';
import '../datasources/badge_data_source.dart';

@LazySingleton(as: BadgeRepository)
class BadgeRepositoryImpl implements BadgeRepository {
  final BadgeDataSource dataSource;

  BadgeRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<UserBadgeEntity>>>
  getPendingCelebrations() async {
    try {
      final models = await dataSource.getPendingCelebrations();
      return Right(models.map((m) => m.toEntity()).toList());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('getPendingCelebrations error: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> markCelebrated(String badgeId) async {
    try {
      await dataSource.markCelebrated(badgeId);
      return const Right(unit);
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('markCelebrated error: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }
}
