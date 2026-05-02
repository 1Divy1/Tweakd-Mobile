class ProfileEntity {
  final String id;
  final String role;
  final String name;
  final String username;
  final String avatarUrl;
  final String bio;
  final String externalLink;
  final int followersCount;
  final int followingCount;
  final bool isVerified;
  final bool isBusiness;
  final bool requiresOnboarding;

  const ProfileEntity({
    required this.id,
    required this.role,
    required this.name,
    required this.username,
    required this.avatarUrl,
    required this.bio,
    required this.externalLink,
    required this.followersCount,
    required this.followingCount,
    required this.isVerified,
    required this.isBusiness,
    required this.requiresOnboarding,
  });
}
