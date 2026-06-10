import '../../domain/entities/follow_list_user.dart';

class FollowUserModel {
  final String id;
  final String username;
  final String? avatarUrl;
  final bool isFollowing;

  const FollowUserModel({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.isFollowing,
  });

  factory FollowUserModel.fromJson(Map<String, dynamic> json) {
    return FollowUserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
      isFollowing: json['is_following'] as bool? ?? false,
    );
  }

  FollowListUserEntity toEntity() => FollowListUserEntity(
        id: id,
        username: username,
        avatarUrl: avatarUrl,
        isFollowing: isFollowing,
      );
}
