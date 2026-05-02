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
}
