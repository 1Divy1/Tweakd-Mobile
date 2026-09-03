import '../../domain/entities/user_badge.dart';
import 'badge_model.dart';

/// Wire model for `UserBadgeDto` — the shape the profile payload embeds and
/// the badge-row endpoints return.
class UserBadgeModel {
  final BadgeModel badge;
  final DateTime? earnedAt;

  const UserBadgeModel({required this.badge, this.earnedAt});

  factory UserBadgeModel.fromJson(Map<String, dynamic> json) {
    final earnedAt = json['earned_at'] as String?;
    return UserBadgeModel(
      badge: BadgeModel.fromJson(json['badge'] as Map<String, dynamic>),
      earnedAt: earnedAt == null ? null : DateTime.tryParse(earnedAt),
    );
  }

  UserBadgeEntity toEntity() {
    return UserBadgeEntity(badge: badge.toEntity(), earnedAt: earnedAt);
  }
}
