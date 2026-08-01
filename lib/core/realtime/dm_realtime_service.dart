/// Live DM events, carried by Supabase Realtime Broadcast on private
/// `user:<uuid>` topics — one topic per user, replacing the Spring STOMP
/// destination `/user/queue/dms`.
///
/// Every payload is authored by the client that performed the action, right
/// after its write succeeded, and is **display-only**: the durable truth lives
/// in the database and comes back from the Spring REST endpoints on any
/// history load. A dropped broadcast costs a live update, never data.
sealed class DmRealtimeEvent {
  const DmRealtimeEvent();
}

/// `message.created` — broadcast by the sender to the recipient's topic and to
/// their own (other devices). [message] is the raw wire object, same shape as
/// the REST message including hydrated `tagged_cars`; decoding to an entity
/// happens in the messages data layer, which owns the models — core stays
/// feature-agnostic.
class DmMessageCreatedEvent extends DmRealtimeEvent {
  final String conversationId;
  final Map<String, dynamic> message;

  const DmMessageCreatedEvent({
    required this.conversationId,
    required this.message,
  });
}

/// `message.deleted` — a message was soft-deleted by its sender.
class DmMessageDeletedEvent extends DmRealtimeEvent {
  final String conversationId;
  final String messageId;

  const DmMessageDeletedEvent({
    required this.conversationId,
    required this.messageId,
  });
}

/// `conversation.read` — [userId] read the conversation up to
/// [lastReadMessageId] (their new watermark).
class DmConversationReadEvent extends DmRealtimeEvent {
  final String conversationId;
  final String userId;
  final String? lastReadMessageId;

  const DmConversationReadEvent({
    required this.conversationId,
    required this.userId,
    this.lastReadMessageId,
  });
}

/// `typing` — the peer started/stopped typing in a conversation. Ephemeral:
/// nothing is written anywhere for it.
class DmTypingEvent extends DmRealtimeEvent {
  final String conversationId;
  final String userId;
  final bool isTyping;

  const DmTypingEvent({
    required this.conversationId,
    required this.userId,
    required this.isTyping,
  });
}

/// The app-wide DM realtime layer.
///
/// The viewer subscribes to their own `user:<my_id>` topic at app start (see
/// main.dart) and stays subscribed for the whole session. Publishing to a peer
/// happens on `user:<peer_id>`, which the RLS policies allow **write-only** for
/// anyone who already shares a conversation with that peer — a sender can
/// reach the topic but never read it.
abstract class DmRealtimeService {
  /// Broadcast stream of events addressed to the viewer.
  Stream<DmRealtimeEvent> get events;

  /// Subscribes to the viewer's own topic (no-op when already active).
  /// Requires a signed-in session.
  void connect();

  /// Unsubscribes from every topic this service holds.
  Future<void> disconnect();

  /// Publishes a just-sent message to [peerId] and to the viewer's own topic.
  /// [message] must be the full wire shape the peer can render as-is,
  /// including hydrated `tagged_cars`.
  void broadcastMessageCreated({
    required String peerId,
    required String conversationId,
    required Map<String, dynamic> message,
  });

  /// Publishes a soft-delete so the peer's open chat swaps the bubble for the
  /// "Message deleted" placeholder.
  void broadcastMessageDeleted({
    required String peerId,
    required String conversationId,
    required String messageId,
  });

  /// Publishes the viewer's new read watermark so the peer's own messages flip
  /// to "Seen".
  void broadcastConversationRead({
    required String peerId,
    required String conversationId,
    String? lastReadMessageId,
  });

  /// Fire-and-forget typing signal (callers throttle). Dropped silently when
  /// the topic isn't reachable — typing is cosmetic and never queued.
  void sendTyping({
    required String peerId,
    required String conversationId,
    required bool isTyping,
  });
}
