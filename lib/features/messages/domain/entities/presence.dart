import 'package:equatable/equatable.dart';

/// One user's live online state, observed on the global presence channel.
///
/// There is no last-seen timestamp: Supabase Presence reports who is connected
/// right now and nothing about the past, so the UI shows "Active now" or
/// nothing at all.
class PresenceEntity extends Equatable {
  final String userId;
  final bool online;

  const PresenceEntity({
    required this.userId,
    required this.online,
  });

  @override
  List<Object?> get props => [userId, online];
}
