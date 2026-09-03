import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/error/base_failures.dart';
import '../../domain/entities/badge.dart';
import '../../domain/failures/badge_failures.dart';
import '../../domain/repositories/badge_repository.dart';
import '../datasources/badge_data_source.dart';

@LazySingleton(as: BadgeRepository)
class BadgeRepositoryImpl implements BadgeRepository {
  final BadgeDataSource dataSource;

  BadgeRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<BadgeEntity>>> getMyLockedBadges() async {
    try {
      final models = await dataSource.getMyLockedBadges();
      return Right(models.map((m) => m.toEntity()).toList());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 404) return const Left(BadgesNotFoundFailure());
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('getMyLockedBadges error: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }
}
