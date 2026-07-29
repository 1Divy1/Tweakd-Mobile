import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/error/base_failures.dart';
import '../../../../core/services/image_service.dart';
import '../../domain/entities/language_option.dart';
import '../../domain/entities/profile.dart';
import '../../domain/failures/profile_failures.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasource/avatar_storage_api_data_source.dart';
import '../datasource/profile_api_data_source.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileApiDataSource profileApiDataSource;
  final AvatarStorageApiDataSource avatarStorageApiDataSource;
  final ImageService imageService;
  ProfileEntity? _cachedProfile;

  ProfileRepositoryImpl(
    this.profileApiDataSource,
    this.avatarStorageApiDataSource,
    this.imageService,
  );

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

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile({
    String? name,
    String? bio,
  }) async {
    try {
      final profile =
          await profileApiDataSource.updateProfile(name: name, bio: bio);
      _cachedProfile = profile.toEntity();
      return Right(_cachedProfile!);
    } on UnauthenticatedException catch (e) {
      return Left(UnauthenticatedFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 400) {
        return Left(ProfileUpdateValidationFailure(e.message));
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('Unexpected error in updateProfile: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> changeAvatar(String imagePath) async {
    try {
      // Step 1 — mint a presigned slot (authed).
      final slot = await avatarStorageApiDataSource.getAvatarUploadSlot();
      // Step 2 — compress to WebP and PUT the bytes to R2 (presigned, no auth;
      // ImageService uses its own bare Dio so the AuthInterceptor never runs).
      final bytes = await imageService.compressToWebp(imagePath);

      await imageService.uploadToR2(slot.uploadUrl, bytes);
      // Step 3 — commit the key; the backend returns the refreshed profile.
      final profile = await profileApiDataSource.setAvatar(slot.key);
      _cachedProfile = profile.toEntity();
      return Right(_cachedProfile!);
    } on UnauthenticatedException catch (e) {
      return Left(UnauthenticatedFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ApiException catch (e) {
      if (e.statusCode == 400) {
        return Left(ProfileUpdateValidationFailure(e.message));
      }
      return Left(AvatarUploadFailure(e.message));
    } on ServerException catch (e) {
      // Compression or the R2 PUT failed. Log the underlying detail (the R2
      // status code + body live in e.message) — it is otherwise flattened into a
      // generic error code by the presentation layer.
      debugPrint('changeAvatar upload failed: ${e.message}');
      return Left(AvatarUploadFailure(e.message));
    } catch (e) {
      debugPrint('Unexpected error in changeAvatar: $e');
      return const Left(AvatarUploadFailure());
    }
  }

  @override
  Future<Either<Failure, List<LanguageOptionEntity>>>
      getLanguageOptions() async {
    try {
      final models = await profileApiDataSource.getLanguageOptions();
      return Right(models.map((m) => m.toEntity()).toList());
    } on UnauthenticatedException catch (e) {
      return Left(UnauthenticatedFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('Unexpected error in getLanguageOptions: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> setAppLanguage(
    String languageId,
  ) async {
    try {
      final profile = await profileApiDataSource.setAppLanguage(languageId);
      _cachedProfile = profile.toEntity();
      return Right(_cachedProfile!);
    } on UnauthenticatedException catch (e) {
      return Left(UnauthenticatedFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 400) {
        return const Left(LanguageUpdateFailure());
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('Unexpected error in setAppLanguage: $e');
      return const Left(LanguageUpdateFailure());
    }
  }
}
