import '../../domain/entities/follow_user.dart';

class FollowUserModel {
  final String id;
  final String username;
  final String? avatarUrl;

  const FollowUserModel({
    required this.id,
    required this.username,
    required this.avatarUrl,
  });

  factory FollowUserModel.fromJson(Map<String, dynamic> json) {
    return FollowUserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  FollowUserEntity toEntity() => FollowUserEntity(
        id: id,
        username: username,
        avatarUrl: avatarUrl,
      );
}
