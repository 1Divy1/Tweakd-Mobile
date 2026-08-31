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

  // ── Identity prefill ────────────────────────────────────────────────────
  /// The display name the sign-up provider supplied, or null when it gave none.
  /// Synchronous: a local read of the cached session, not a network call.
  String? get providerFullName;

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
  /// The user's display name. Required: a social provider prefills it, but
  /// Apple supplies a name only on a first-ever sign-in and email/password
  /// accounts never have one, so onboarding is the one place every account is
  /// guaranteed to pass through with a chance to set it.
  final String name;
  final String username;
  final String? bio;
  final String cityId;
  final int discoveryRadiusKm;
  final NotificationPreferences notifications;
  final List<DreamCarEntity> dreamCars;

  const OnboardingSubmissionParams({
    required this.name,
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
        'name': name,
        'username': username,
        if (bio != null && bio!.isNotEmpty) 'bio': bio,
        'city_id': cityId,
        'discovery_radius_km': discoveryRadiusKm,
      };
}
