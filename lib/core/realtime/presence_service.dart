/// One user's online state, as observed on the global presence channel.
class UserPresence {
  final String userId;
  final bool online;

  const UserPresence({required this.userId, required this.online});
}

/// App-wide online presence, backed by Supabase Realtime Presence on a single
/// global topic (`presence:online`).
///
/// Every signed-in client joins at app start and tracks itself, so one
/// subscription powers the inbox ACTIVE NOW strip, the conversation row dots
/// and the chat header. "Online" therefore means exactly "has the app open",
/// same as the Spring presence it replaces.
///
/// There is no last-seen timestamp: Presence reports who is here now and
/// nothing about the past.
abstract class PresenceService {
  /// Flips only — one event per user whose state actually changed.
  Stream<UserPresence> get updates;

  /// Everyone currently online, for a synchronous snapshot on page open.
  Set<String> get onlineUserIds;

  /// Joins the channel and starts tracking the viewer (no-op when already
  /// active). Requires a signed-in session.
  void connect();

  /// Stops tracking the viewer and leaves the channel.
  Future<void> disconnect();
}
