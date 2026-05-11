import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/error/base_failures.dart';
import '../../domain/entities/follow_request.dart';
import '../../domain/entities/follow_status.dart';
import '../../domain/entities/follow_user.dart';
import '../../domain/failures/follow_failures.dart';
import '../../domain/repositories/follow_repository.dart';
import '../datasource/follow_api_data_source.dart';

@LazySingleton(as: FollowRepository)
class FollowRepositoryImpl implements FollowRepository {
  final FollowApiDataSource followApiDataSource;

  FollowRepositoryImpl(this.followApiDataSource);

  @override
  Future<Either<Failure, FollowStatusEntity>> follow(String username) async {
    try {
      final model = await followApiDataSource.follow(username);
      return Right(model.toEntity());
    } on UnauthenticatedException catch (e) {
      return Left(UnauthenticatedFollowFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ApiException catch (e) {
      if (e.statusCode == 400) return Left(CannotFollowSelfFailure(e.message));
      if (e.statusCode == 404) return Left(TargetUserNotFoundFailure(e.message));
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('Unexpected error in follow: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> unfollow(String username) async {
    try {
      await followApiDataSource.unfollow(username);
      return const Right(unit);
    } on UnauthenticatedException catch (e) {
      return Left(UnauthenticatedFollowFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ApiException catch (e) {
      if (e.statusCode == 404) return Left(TargetUserNotFoundFailure(e.message));
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('Unexpected error in unfollow: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, FollowStatusEntity>> getFollowStatus(
    String username,
  ) async {
    try {
      final model = await followApiDataSource.getFollowStatus(username);
      return Right(model.toEntity());
    } on UnauthenticatedException catch (e) {
      return Left(UnauthenticatedFollowFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ApiException catch (e) {
      if (e.statusCode == 404) return Left(TargetUserNotFoundFailure(e.message));
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('Unexpected error in getFollowStatus: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, List<FollowRequestEntity>>> getPendingRequests() async {
    try {
      final models = await followApiDataSource.getPendingRequests();
      return Right(models.map((m) => m.toEntity()).toList());
    } on UnauthenticatedException catch (e) {
      return Left(UnauthenticatedFollowFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('Unexpected error in getPendingRequests: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> acceptRequest(String username) async {
    try {
      await followApiDataSource.acceptRequest(username);
      return const Right(unit);
    } on UnauthenticatedException catch (e) {
      return Left(UnauthenticatedFollowFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ApiException catch (e) {
      if (e.statusCode == 404) return Left(FollowRequestNotFoundFailure(e.message));
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('Unexpected error in acceptRequest: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> rejectRequest(String username) async {
    try {
      await followApiDataSource.rejectRequest(username);
      return const Right(unit);
    } on UnauthenticatedException catch (e) {
      return Left(UnauthenticatedFollowFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ApiException catch (e) {
      if (e.statusCode == 404) return Left(FollowRequestNotFoundFailure(e.message));
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('Unexpected error in rejectRequest: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, List<FollowUserEntity>>> getFollowers(
    String username,
  ) async {
    try {
      final models = await followApiDataSource.getFollowers(username);
      return Right(models.map((m) => m.toEntity()).toList());
    } on UnauthenticatedException catch (e) {
      return Left(UnauthenticatedFollowFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ApiException catch (e) {
      if (e.statusCode == 403) return Left(PrivateProfileFailure(e.message));
      if (e.statusCode == 404) return Left(TargetUserNotFoundFailure(e.message));
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('Unexpected error in getFollowers: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, List<FollowUserEntity>>> getFollowing(
    String username,
  ) async {
    try {
      final models = await followApiDataSource.getFollowing(username);
      return Right(models.map((m) => m.toEntity()).toList());
    } on UnauthenticatedException catch (e) {
      return Left(UnauthenticatedFollowFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ApiException catch (e) {
      if (e.statusCode == 403) return Left(PrivateProfileFailure(e.message));
      if (e.statusCode == 404) return Left(TargetUserNotFoundFailure(e.message));
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('Unexpected error in getFollowing: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }
}
