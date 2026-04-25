import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profilePictureUrl;
  final String? username;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.profilePictureUrl,
    this.username,
  });

  factory UserModel.fromAuthAndProfile({
    required User authUser,
    required Map<String, dynamic> profileData,
  }) {
    return UserModel(
      id: authUser.id,
      email: authUser.email ?? '',
      name: profileData['name'],
      profilePictureUrl: profileData['avatar_url'],
      username: profileData['username'],
    );
  }

  factory UserModel.fromSupabase(User supabaseUser) {
    final metadata = supabaseUser.userMetadata;

    return UserModel(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      name: (metadata?['full_name'] ?? metadata?['name']) as String? ?? '',
      profilePictureUrl:
          (metadata?['avatar_url'] ?? metadata?['picture']) as String?,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      profilePictureUrl: profilePictureUrl,
      username: username,
    );
  }
}
