import '../../domain/entities/follow_request.dart';

class FollowRequestModel {
  final String profileId;
  final String username;
  final String? avatarUrl;
  final DateTime requestedAt;

  const FollowRequestModel({
    required this.profileId,
    required this.username,
    required this.avatarUrl,
    required this.requestedAt,
  });

  factory FollowRequestModel.fromJson(Map<String, dynamic> json) {
    return FollowRequestModel(
      profileId: json['profile_id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
      requestedAt: DateTime.parse(json['requested_at'] as String),
    );
  }

  FollowRequestEntity toEntity() => FollowRequestEntity(
        profileId: profileId,
        username: username,
        avatarUrl: avatarUrl,
        requestedAt: requestedAt,
      );
}
