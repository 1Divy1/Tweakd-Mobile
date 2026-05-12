import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/error/base_failures.dart';
import '../../domain/entities/profile.dart';
import '../../domain/failures/profile_failures.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasource/profile_api_data_source.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileApiDataSource profileApiDataSource;
  ProfileEntity? _cachedProfile;

  ProfileRepositoryImpl(this.profileApiDataSource);

  @override
  Future<Either<Failure, ProfileEntity>> getCurrentUserProfile({bool forceRefresh = false}) async {
    
    // Return cached profile if available and not forcing refresh
    if (!forceRefresh && _cachedProfile != null) {
      return Right(_cachedProfile!);
    }
    try {
      final profile = await profileApiDataSource.getCurrentUserProfile();
      _cachedProfile = profile.toEntity();
      return Right(_cachedProfile!);
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('Unexpected error in getCurrentUserProfile: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> submitOnboarding({
    required String username,
    String? bio,
  }) async {
    try {
      final profile = await profileApiDataSource.submitOnboarding(
        username: username,
        bio: bio,
      );
      return Right(profile.toEntity());
    } on ConflictException {
      return const Left(UsernameTakenFailure());
    } on UnauthenticatedException catch (e) {
      return Left(UnauthenticatedFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 400) {
        return Left(InvalidUsernameFailure(e.message));
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('Unexpected error in submitOnboarding: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> getProfileByUsername(
    String username,
  ) async {
    try {
      final profile = await profileApiDataSource.getProfileByUsername(username);
      return Right(profile.toEntity());
    } on UnauthenticatedException catch (e) {
      return Left(UnauthenticatedFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        return const Left(ProfileNotFoundFailure());
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('Unexpected error in getProfileByUsername: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }
}
