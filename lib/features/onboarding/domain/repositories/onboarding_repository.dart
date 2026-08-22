import 'package:tweakd/features/profile/domain/entities/profile.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/base_failures.dart';
import '../entities/dream_car_draft.dart';
import '../entities/notification_preferences.dart';
import '../entities/onboarding reference/city_entity.dart';
import '../entities/onboarding reference/country_entity.dart';

abstract class OnboardingRepository {
  // ── Reference data ──────────────────────────────────────────────────────
  Future<Either<Failure, List<CountryEntity>>> getCountries();
  Future<Either<Failure, List<CityEntity>>> getCities(String countryId);

  // ── Username availability ───────────────────────────────────────────────
  /// Returns `true` when [username] is still available, `false` when it is
  /// already taken. [cancelToken] aborts the check if the user keeps typing.
  Future<Either<Failure, bool>> checkUsernameAvailable(
    String username, {
    CancelToken? cancelToken,
  });

  // ── Submit ──────────────────────────────────────────────────────────────
  /// Commits onboarding: posts the core profile payload (the call that flips
  /// `requiresOnboarding`), then best-effort persists notification prefs and
  /// any dream cars. Returns the created profile.
  Future<Either<Failure, ProfileEntity>> submitOnboarding(
    OnboardingSubmissionParams params,
  );
}

/// The full set of answers collected by the wizard, submitted in one shot.
class OnboardingSubmissionParams {
  final String username;
  final String? bio;
  final String cityId;
  final int discoveryRadiusKm;
  final NotificationPreferences notifications;
  final List<DreamCarEntity> dreamCars;

  const OnboardingSubmissionParams({
    required this.username,
    this.bio,
    required this.cityId,
    required this.discoveryRadiusKm,
    required this.notifications,
    required this.dreamCars,
  });

  /// Body for `POST /profile/onboarding` (notifications and dream cars are sent
  /// via their own endpoints).
  Map<String, dynamic> toOnboardingJson() => {
        'username': username,
        if (bio != null && bio!.isNotEmpty) 'bio': bio,
        'city_id': cityId,
        'discovery_radius_km': discoveryRadiusKm,
      };
}
