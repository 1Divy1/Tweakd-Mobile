import 'package:car_social_media_app/features/profile/data/models/profile_model.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/abstract_http.dart';
import '../models/onboarding reference/car_category_model.dart';
import '../models/onboarding reference/city_model.dart';
import '../models/onboarding reference/community_role_model.dart';
import '../models/onboarding reference/country_model.dart';

@lazySingleton
class OnboardingApiDataSource {
  final AbstractHTTP http;

  OnboardingApiDataSource(this.http);

  // ── Reference data (read-only) ──────────────────────────────────────────

  Future<List<CountryModel>> getCountries() async {
    final data = await http.get('/profile/reference/countries');
    return (data as List<dynamic>)
        .map((e) => CountryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CityModel>> getCities(String countryId) async {
    final data =
        await http.get('/profile/reference/countries/$countryId/cities');
    return (data as List<dynamic>)
        .map((e) => CityModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CommunityRoleModel>> getCommunityRoles() async {
    final data = await http.get('/profile/reference/community-roles');
    return (data as List<dynamic>)
        .map((e) => CommunityRoleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CarCategoryModel>> getCarCategories() async {
    final data = await http.get('/profile/reference/car-categories');
    return (data as List<dynamic>)
        .map((e) => CarCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Username availability ───────────────────────────────────────────────

  /// `GET /profile/exists/{username}`. Returns `true` when the handle is
  /// already taken, `false` when it is free. [cancelToken] lets the caller
  /// abort an in-flight check when the user keeps typing.
  Future<bool> checkUsernameExists(
    String username, {
    CancelToken? cancelToken,
  }) async {
    final data = await http.get(
      '/profile/exists/$username',
      cancelToken: cancelToken,
    );
    return data as bool;
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  /// `POST /profile/onboarding`. [body] must carry username, city_id,
  /// discovery_radius_km and non-empty category_ids / role_ids; bio is
  /// optional. Returns the freshly created profile.
  Future<ProfileModel> submitOnboarding(Map<String, dynamic> body) async {
    final data = await http.post('/profile/onboarding', body: body);
    return ProfileModel.fromJson(data as Map<String, dynamic>);
  }

  /// `PUT /profile/me/notifications`. Every flag must be present.
  Future<void> updateNotifications(Map<String, dynamic> body) async {
    await http.put('/profile/me/notifications', body: body);
  }

  /// `POST /garage/dream-cars`. Sends every dream car in a single batch under
  /// the `dream_cars` key.
  Future<void> addDreamCars(List<Map<String, dynamic>> dreamCars) async {
    await http.post('/garage/dream-cars', body: {'dream_cars': dreamCars});
  }
}
