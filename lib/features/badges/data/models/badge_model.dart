import '../../domain/entities/badge.dart';

/// Wire model for `BadgeDto`. Keys are snake_case, per the backend's Jackson
/// naming strategy.
class BadgeModel {
  final String id;
  final String title;
  final String? description;
  final String unlockedUrl;
  final String? lockedUrl;
  final bool available;
  final DateTime? createdAt;

  const BadgeModel({
    required this.id,
    required this.title,
    required this.unlockedUrl,
    this.description,
    this.lockedUrl,
    this.available = true,
    this.createdAt,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    final createdAt = json['created_at'] as String?;
    return BadgeModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      unlockedUrl: json['unlocked_url'] as String? ?? '',
      lockedUrl: json['locked_url'] as String?,
      available: json['available'] as bool? ?? true,
      createdAt: createdAt == null ? null : DateTime.tryParse(createdAt),
    );
  }

  BadgeEntity toEntity() {
    return BadgeEntity(
      id: id,
      title: title,
      description: description,
      unlockedUrl: unlockedUrl,
      lockedUrl: lockedUrl,
      available: available,
      createdAt: createdAt,
    );
  }
}
