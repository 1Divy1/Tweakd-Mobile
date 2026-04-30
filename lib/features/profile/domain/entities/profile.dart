class ProfileEntity {
  final String name;
  final String username;
  final String bio;
  final String profilePictureUrl;
  final String externalLink;
  final int followersCount;
  final int followingCount;
  final bool isVerified;
  final bool isBusiness;

  ProfileEntity({
    required this.name,
    required this.username,
    required this.bio,
    required this.profilePictureUrl,
    required this.externalLink,
    required this.followersCount,
    required this.followingCount,
    required this.isVerified,
    required this.isBusiness,
  });
}