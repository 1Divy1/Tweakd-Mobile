import 'package:equatable/equatable.dart';

/// One user's presence: online right now, or last seen at [lastSeenAt].
/// [lastSeenAt] is null while online, and also null for users who were never
/// seen online (in which case nothing is rendered).
class PresenceEntity extends Equatable {
  final String userId;
  final bool online;
  final DateTime? lastSeenAt;

  const PresenceEntity({
    required this.userId,
    required this.online,
    this.lastSeenAt,
  });

  @override
  List<Object?> get props => [userId, online, lastSeenAt];
}
