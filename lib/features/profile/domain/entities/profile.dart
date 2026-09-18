import 'package:tweakd/features/badges/domain/entities/user_badge.dart';

class ProfileEntity {
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

  /// Community reputation: points earned by taking part — attending meets,
  /// placing in contests, contributing to the forums.
  ///
  /// Always a real number, and `0` is a real answer: the backend returns a
  /// score for every account and clamps penalties at zero, so a brand-new user
  /// is a genuine `0` rather than an unknown. The breakdown and the timeline
  /// behind it live at `/api/v1/reputation`; the profile only needs the total.
  final int reputationScore;

  /// The badges this user has unlocked, newest first. Embedded in the profile
  /// payload, so the strip never costs a second request. Empty, never null.
  ///
  /// What they haven't unlocked is a separate read (`GET /badges/me/locked`)
  /// and exists for your own profile only.
  final List<UserBadgeEntity> badges;

  const ProfileEntity({
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

  ProfileEntity copyWith({int? followersCount}) {
    return ProfileEntity(
      id: id,
      name: name,
      username: username,
      avatarUrl: avatarUrl,
      bio: bio,
      externalLink: externalLink,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount,
      isVerified: isVerified,
      isBusiness: isBusiness,
      requiresOnboarding: requiresOnboarding,
      appLanguage: appLanguage,
      reputationScore: reputationScore,
      badges: badges,
    );
  }
}
