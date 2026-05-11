class FollowRequestEntity {
  final String profileId;
  final String username;
  final String? avatarUrl;
  final DateTime requestedAt;

  const FollowRequestEntity({
    required this.profileId,
    required this.username,
    required this.avatarUrl,
    required this.requestedAt,
  });
}
