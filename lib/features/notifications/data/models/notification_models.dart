import '../../domain/entities/notification.dart';

DateTime _parseInstant(dynamic raw) =>
    (raw is String ? DateTime.tryParse(raw)?.toLocal() : null) ??
    DateTime.now();

/// Coerces a raw `payload` object into a `Map<String, String>`. The backend
/// promises all-string values, but we stringify defensively so a stray
/// non-string never throws during parsing.
Map<String, String> _parsePayload(dynamic raw) {
  if (raw is! Map) return const {};
  final out = <String, String>{};
  raw.forEach((key, value) {
    if (value != null) out['$key'] = '$value';
  });
  return out;
}

/// Wire model for a single NotificationDto (snake_case). Maps to
/// [NotificationEntity] with the typed enum resolved from the raw `type`.
class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String? body;
  final Map<String, String> payload;
  final bool read;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.payload,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: '${json['id']}',
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String?,
      payload: _parsePayload(json['payload']),
      read: json['read'] as bool? ?? false,
      createdAt: _parseInstant(json['created_at']),
    );
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      type: NotificationType.fromWire(type),
      rawType: type,
      title: title,
      body: body,
      payload: payload,
      read: read,
      createdAt: createdAt,
    );
  }
}

/// Wire model for a cursor page of notifications.
class NotificationPageModel {
  final List<NotificationModel> items;
  final String? nextCursor;

  const NotificationPageModel({required this.items, required this.nextCursor});

  factory NotificationPageModel.fromJson(Map<String, dynamic> json) {
    return NotificationPageModel(
      items: [
        for (final item in json['items'] as List? ?? const [])
          NotificationModel.fromJson(item as Map<String, dynamic>),
      ],
      nextCursor: json['next_cursor'] as String?,
    );
  }

  NotificationPageEntity toEntity() {
    return NotificationPageEntity(
      items: [for (final item in items) item.toEntity()],
      nextCursor: nextCursor,
    );
  }
}
