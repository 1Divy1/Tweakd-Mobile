import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user.dart';

class UserModel {
  final String id;
  final bool requiresOnboarding;

  const UserModel({required this.id, required this.requiresOnboarding});

  factory UserModel.fromProfile(User supabaseUser, Map<String, dynamic> profile) {
    return UserModel(
      id: supabaseUser.id,
      requiresOnboarding: profile['requires_onboarding'] as bool? ?? true,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      requiresOnboarding: json['requires_onboarding'] as bool? ?? false,
    );
  }

  UserEntity toEntity() {
    return UserEntity(id: id, requiresOnboarding: requiresOnboarding);
  }
}
