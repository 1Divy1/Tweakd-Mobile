import '../../domain/entities/profile.dart';

class ProfileModel {
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

  const ProfileModel({
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

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      role: json['role'] as String? ?? '',
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      externalLink: json['external_link'] as String? ?? '',
      followersCount: json['followers_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      isBusiness: json['is_business'] as bool? ?? false,
      requiresOnboarding: json['requires_onboarding'] as bool? ?? false,
    );
  }

  ProfileEntity toEntity() {
    return ProfileEntity(
      id: id,
      role: role,
      name: name,
      username: username,
      avatarUrl: avatarUrl,
      bio: bio,
      externalLink: externalLink,
      followersCount: followersCount,
      followingCount: followingCount,
      isVerified: isVerified,
      isBusiness: isBusiness,
      requiresOnboarding: requiresOnboarding,
    );
  }
}
