import '../../../badges/data/models/user_badge_model.dart';
import '../../domain/entities/profile.dart';

class ProfileModel {
  final String id;
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
  final String appLanguage;
  final int reputationScore;
  final List<UserBadgeModel> badges;

  const ProfileModel({
    required this.id,
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
    required this.appLanguage,
    this.reputationScore = 0,
    this.badges = const [],
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
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
      appLanguage: json['app_language'] as String? ?? 'en',
      reputationScore: json['reputation_score'] as int? ?? 0,
      // Always present on a live payload ([] when the user has none); the
      // fallback only covers a fixture or an older stub.
      badges: ((json['badges'] as List?) ?? const [])
          .map((e) => UserBadgeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  ProfileEntity toEntity() {
    return ProfileEntity(
      id: id,
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
      appLanguage: appLanguage,
      reputationScore: reputationScore,
      badges: badges.map((b) => b.toEntity()).toList(),
    );
  }
}
