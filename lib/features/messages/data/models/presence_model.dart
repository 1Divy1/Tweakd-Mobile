import '../../domain/entities/presence.dart';

/// Wire model for one entry of `GET /presence?user_ids=…`:
/// `{ "user_id": "...", "online": true, "last_seen_at": null }`.
class PresenceModel {
  final String userId;
  final bool online;
  final DateTime? lastSeenAt;

  const PresenceModel({
    required this.userId,
    required this.online,
    this.lastSeenAt,
  });

  factory PresenceModel.fromJson(Map<String, dynamic> json) {
    final lastSeenRaw = json['last_seen_at'];
    return PresenceModel(
      userId: json['user_id'] as String,
      online: json['online'] as bool? ?? false,
      lastSeenAt: lastSeenRaw is String
          ? DateTime.tryParse(lastSeenRaw)?.toLocal()
          : null,
    );
  }

  PresenceEntity toEntity() => PresenceEntity(
        userId: userId,
        online: online,
        lastSeenAt: lastSeenAt,
      );
}
