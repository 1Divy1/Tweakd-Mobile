import 'package:injectable/injectable.dart';

import '../../../../core/network/abstract_http.dart';
import '../models/user_model.dart';

@lazySingleton
class AuthApiDataSource {
  final AbstractHTTP http;

  AuthApiDataSource(this.http);

  Future<UserModel> submitUsername(String username) async {
    final data = await http.post(
      '/onboarding/username',
      body: {'username': username},
    );
    return UserModel.fromJson(data as Map<String, dynamic>);
  }
}
