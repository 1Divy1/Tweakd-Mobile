import 'package:dartz/dartz.dart';

import '../../../../core/error/base_failures.dart';
import '../entities/language_option.dart';
import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getCurrentUserProfile({bool forceRefresh});

  Future<Either<Failure, ProfileEntity>> submitOnboarding({
    required String username,
    String? bio,
  });

  Future<Either<Failure, ProfileEntity>> getProfileByUsername(String username);

  /// Updates the current user's editable profile fields. Only non-null fields
  /// are sent: `null` = leave unchanged, `''` = clear.
  Future<Either<Failure, ProfileEntity>> updateProfile({
    String? name,
    String? bio,
  });

  /// Runs the 3-step avatar pipeline for the local image at [imagePath]:
  /// mint a presigned slot → compress to WebP → PUT to R2 → commit the key.
  /// Returns the refreshed profile carrying the new public `avatar_url`.
  Future<Either<Failure, ProfileEntity>> changeAvatar(String imagePath);

  /// The selectable app languages (id = locale code, label = display name).
  Future<Either<Failure, List<LanguageOptionEntity>>> getLanguageOptions();

  /// Sets the current user's app language to [languageId] (a locale code from
  /// [getLanguageOptions]). Returns the refreshed profile.
  Future<Either<Failure, ProfileEntity>> setAppLanguage(String languageId);
}
