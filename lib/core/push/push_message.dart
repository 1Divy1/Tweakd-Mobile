/// One push notification, reduced to the parts the app acts on.
///
/// Deliberately feature-agnostic — same reasoning as `core/realtime/`: `core`
/// owns no feature vocabulary, so the raw all-string `data` map travels as-is
/// and the decoding into a route or an entity happens at the edges.
///
/// [title]/[body] are only populated for the `notification` block the backend
/// sends alongside `data`. They are absent for a data-only message, and on
/// iOS they are absent when the system already rendered the banner itself.
class PushMessage {
  /// The FCM `data` block. FCM guarantees every value is a string on the wire,
  /// but a stray non-string is stringified on the way in (see [coercePushData])
  /// so one malformed message never throws during parsing — the same
  /// defensiveness the REST `payload` parser already applies.
  final Map<String, String> data;

  final String? title;
  final String? body;

  const PushMessage({required this.data, this.title, this.body});

  /// Wire `type`, sharing the vocabulary of `NotificationType.fromWire` so a
  /// push and its REST twin resolve to the same kind.
  String get type => data['type'] ?? '';

  /// Id of the persisted notification row this push mirrors, when there is
  /// one. Used to collapse a re-delivered push onto the same OS notification
  /// instead of stacking duplicates.
  String? get notificationId => data['notification_id'];

  /// Authoritative unread count as of send time, when the backend includes it.
  /// Lets the badge update without a round-trip; null means "go ask".
  int? get unreadCount {
    final raw = data['unread_count'];
    return raw == null ? null : int.tryParse(raw);
  }
}

/// Coerces a raw FCM `data` map into `Map<String, String>`, dropping nulls.
Map<String, String> coercePushData(Map<String, dynamic> raw) {
  final out = <String, String>{};
  raw.forEach((key, value) {
    if (value != null) out[key.toString()] = value.toString();
  });
  return out;
}
