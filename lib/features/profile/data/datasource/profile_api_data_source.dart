import 'package:injectable/injectable.dart';

import '../../../../core/network/abstract_http.dart';
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
}
