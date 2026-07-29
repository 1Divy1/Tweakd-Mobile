/// Events pushed to the viewer over the app-wide DM socket
/// (STOMP destination `/user/queue/dms`). The server sends one sparse
/// envelope shape discriminated by `type`; each variant here carries only
/// the fields populated for it.
sealed class DmSocketEvent {
  const DmSocketEvent();
}

/// `presence` — a user the viewer shares a conversation with flipped
/// online/offline. Not scoped to one conversation. `last_seen_at` is null
/// while online.
class DmPresenceEvent extends DmSocketEvent {
  final String userId;
  final bool online;
  final DateTime? lastSeenAt;

  const DmPresenceEvent({
    required this.userId,
    required this.online,
    this.lastSeenAt,
  });
}

/// `message.created` — delivered to the recipient and to the sender's other
/// devices. [message] is the raw wire object (same shape as the REST message);
/// decoding to an entity happens in the messages data layer, which owns the
/// models — core stays feature-agnostic.
class DmMessageCreatedEvent extends DmSocketEvent {
  final String conversationId;
  final Map<String, dynamic> message;

  const DmMessageCreatedEvent({
    required this.conversationId,
    required this.message,
  });
}

/// `message.deleted` — a message was soft-deleted by its sender.
class DmMessageDeletedEvent extends DmSocketEvent {
  final String conversationId;
  final String messageId;

  const DmMessageDeletedEvent({
    required this.conversationId,
    required this.messageId,
  });
}

/// `conversation.read` — [userId] read the conversation up to
/// [lastReadMessageId] (their new watermark).
class DmConversationReadEvent extends DmSocketEvent {
  final String conversationId;
  final String userId;
  final String? lastReadMessageId;

  const DmConversationReadEvent({
    required this.conversationId,
    required this.userId,
    this.lastReadMessageId,
  });
}

/// `typing` — the peer started/stopped typing in a conversation.
class DmTypingEvent extends DmSocketEvent {
  final String conversationId;
  final String userId;
  final bool isTyping;

  const DmTypingEvent({
    required this.conversationId,
    required this.userId,
    required this.isTyping,
  });
}

/// The app-wide `/ws` socket. Connected at app start for any signed-in
/// session — "Active now" literally means "has the app open" — and torn down
/// on sign-out (see main.dart). Consumers only read [events] and fire
/// [sendTyping]; they never manage the connection.
abstract class DmSocketService {
  /// Broadcast stream of decoded socket events.
  Stream<DmSocketEvent> get events;

  /// Opens the connection (no-op when already active). Requires a signed-in
  /// session; the JWT is re-read on every (re)connect attempt.
  void connect();

  /// Closes the connection and stops reconnect attempts.
  Future<void> disconnect();

  /// Fire-and-forget typing signal to `/app/dms/typing`. Dropped silently
  /// when the socket isn't connected — typing is cosmetic and never queued.
  void sendTyping({required String conversationId, required bool isTyping});
}
