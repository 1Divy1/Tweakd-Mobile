import 'package:injectable/injectable.dart';

import '../../../../core/network/abstract_http.dart';
import '../models/language_option_model.dart';
import '../models/profile_model.dart';

@lazySingleton
class ProfileApiDataSource {
  final AbstractHTTP http;

  ProfileApiDataSource(this.http);

  Future<ProfileModel> getCurrentUserProfile() async {
    final data = await http.get('/profile/me');
    return ProfileModel.fromJson(data as Map<String, dynamic>);
  }

  Future<ProfileModel> submitOnboarding({
    required String username,
    String? bio,
  }) async {
    final body = <String, dynamic>{'username': username};
    if (bio != null && bio.isNotEmpty) {
      body['bio'] = bio;
    }

    final data = await http.post('/profile/onboarding', body: body);
    return ProfileModel.fromJson(data as Map<String, dynamic>);
  }

  Future<ProfileModel> getProfileByUsername(String username) async {
    final data = await http.get('/profile/by-username/$username');
    return ProfileModel.fromJson(data as Map<String, dynamic>);
  }

  /// PATCH /profile/me — sends only the provided fields. A `null` argument is
  /// omitted from the body (unchanged); an empty string is sent (clears).
  Future<ProfileModel> updateProfile({String? name, String? bio}) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (bio != null) body['bio'] = bio;

    final data = await http.patch('/profile/me', body: body);
    return ProfileModel.fromJson(data as Map<String, dynamic>);
  }

  /// PATCH /profile/me/avatar — commits a previously uploaded R2 [key].
  Future<ProfileModel> setAvatar(String key) async {
    final data = await http.patch('/profile/me/avatar', body: {'key': key});
    return ProfileModel.fromJson(data as Map<String, dynamic>);
  }

  /// GET /profile/language-options — the selectable app languages.
  Future<List<LanguageOptionModel>> getLanguageOptions() async {
    final data = await http.get('/profile/language-options');
    return (data as List)
        .map((e) => LanguageOptionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// PATCH /profile/me/language — [languageId] is a locale code from
  /// [getLanguageOptions].
  Future<ProfileModel> setAppLanguage(String languageId) async {
    final data = await http.patch(
      '/profile/me/language',
      body: {'language_id': languageId},
    );
    return ProfileModel.fromJson(data as Map<String, dynamic>);
  }
}
