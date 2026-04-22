import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profilePictureUrl;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.profilePictureUrl,
  });

  factory UserModel.fromSupabase(User supabaseUser) {
    final metadata = supabaseUser.userMetadata;

    return UserModel(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      name: (metadata?['full_name'] ?? metadata?['name']) as String? ?? '',
      profilePictureUrl: (metadata?['avatar_url'] ?? metadata?['picture']) as String?,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      profilePictureUrl: profilePictureUrl,
    );
  }
}
