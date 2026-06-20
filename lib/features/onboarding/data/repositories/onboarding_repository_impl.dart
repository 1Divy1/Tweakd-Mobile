import 'package:car_social_media_app/features/profile/domain/entities/profile.dart';
import 'package:car_social_media_app/features/profile/domain/failures/profile_failures.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/error/base_failures.dart';
import '../../domain/entities/onboarding reference/car_category_entity.dart';
import '../../domain/entities/onboarding reference/city_entity.dart';
import '../../domain/entities/onboarding reference/community_role_entity.dart';
import '../../domain/entities/onboarding reference/country_entity.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_api_data_source.dart';

@LazySingleton(as: OnboardingRepository)
class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingApiDataSource dataSource;

  OnboardingRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<CountryEntity>>> getCountries() async {
    try {
      final models = await dataSource.getCountries();
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } catch (e) {
      debugPrint('getCountries error: $e');
      return const Left(UnknownFailure('Failed to load countries.'));
    }
  }

  @override
  Future<Either<Failure, List<CityEntity>>> getCities(String countryId) async {
    try {
      final models = await dataSource.getCities(countryId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } catch (e) {
      debugPrint('getCities error: $e');
      return const Left(UnknownFailure('Failed to load cities.'));
    }
  }

  @override
  Future<Either<Failure, List<CommunityRoleEntity>>> getCommunityRoles() async {
    try {
      final models = await dataSource.getCommunityRoles();
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } catch (e) {
      debugPrint('getCommunityRoles error: $e');
      return const Left(UnknownFailure('Failed to load community roles.'));
    }
  }

  @override
  Future<Either<Failure, List<CarCategoryEntity>>> getCarCategories() async {
    try {
      final models = await dataSource.getCarCategories();
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } catch (e) {
      debugPrint('getCarCategories error: $e');
      return const Left(UnknownFailure('Failed to load car categories.'));
    }
  }

  @override
  Future<Either<Failure, bool>> checkUsernameAvailable(
    String username, {
    CancelToken? cancelToken,
  }) async {
    try {
      final exists = await dataSource.checkUsernameExists(
        username,
        cancelToken: cancelToken,
      );
      return Right(!exists);
    } on RequestCancelledException {
      return const Left(RequestCancelledFailure());
    } on UnauthenticatedException catch (e) {
      return Left(UnauthenticatedFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('checkUsernameAvailable error: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> submitOnboarding(
    OnboardingSubmissionParams params,
  ) async {
    // ── Core profile payload — the call that commits onboarding. ────────────
    final ProfileEntity profile;
    try {
      final model =
          await dataSource.submitOnboarding(params.toOnboardingJson());
      profile = model.toEntity();
    } on ConflictException {
      return const Left(UsernameTakenFailure());
    } on UnauthenticatedException catch (e) {
      return Left(UnauthenticatedFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 400) return Left(InvalidUsernameFailure(e.message));
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('submitOnboarding error: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }

    // ── Secondary, best-effort calls. Onboarding is already committed, so a
    // failure here must not block the user (these are editable later). ──────
    try {
      await dataSource.updateNotifications(params.notifications.toJson());
    } catch (e) {
      debugPrint('updateNotifications (onboarding) failed: $e');
    }

    try {
      if (params.dreamCars.isNotEmpty) {
        await dataSource
            .addDreamCars(params.dreamCars.map((d) => d.toJson()).toList());
      }
    } catch (e) {
      debugPrint('addDreamCars (onboarding) failed: $e');
    }

    return Right(profile);
  }
}
