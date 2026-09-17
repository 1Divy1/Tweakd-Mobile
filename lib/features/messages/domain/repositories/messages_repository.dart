import 'package:dartz/dartz.dart';

import '../../../../core/error/base_failures.dart';
import '../entities/chat.dart';
import '../entities/chat_events.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';
import '../entities/message_user.dart';

abstract class MessagesRepository {
  /// One keyset page of the inbox (most recently active first).
  /// Pass the previous page's cursor to fetch the next one.
  Future<Either<Failure, InboxEntity>> getInbox({String? cursor});

  /// The other participant of [conversationId]. Lets a chat opened by id
  /// alone — a push notification tap — render its header without the peer
  /// having travelled with the navigation.
  Future<Either<Failure, MessageUserEntity>> getConversationPeer(
    String conversationId,
  );

  /// One keyset page of a conversation's history, oldest-first.
  Future<Either<Failure, MessagesPageEntity>> getMessages(
    String conversationId, {
    String? cursor,
  });

  /// Sends a DM addressed by recipient — the first message between two users
  /// creates the conversation implicitly (its id is in the result).
  /// [taggedCars] shares cars from the sender's garage; [text] may be blank
  /// when at least one car is attached. The cars travel as full entities, not
  /// ids, because the peer's copy of the message is broadcast from here and
  /// has to carry cover images with it.
  Future<Either<Failure, SentMessageEntity>> sendMessage(
    String recipientId,
    String text, {
    List<DmTaggedCarEntity> taggedCars,
  });

  /// Soft-deletes the viewer's own message (idempotent server-side) and tells
  /// [peerId] so their open chat swaps in the deleted placeholder.
  Future<Either<Failure, void>> deleteMessage(
    String messageId, {
    required String conversationId,
    required String peerId,
  });

  /// Hides ("deletes") a conversation from the viewer's list only.
  Future<Either<Failure, void>> hideConversation(String conversationId);

  /// Marks the conversation read up to its latest message and pushes the new
  /// watermark to [peerId], flipping their messages to "Seen".
  Future<Either<Failure, void>> markConversationRead(
    String conversationId, {
    required String peerId,
  });

  /// Total unread messages across all conversations (app-level DMs badge).
  Future<Either<Failure, int>> getUnreadCount();

  /// Fire-and-forget typing signal to [peerId] (throttled by callers).
  void sendTyping(
    String conversationId,
    bool isTyping, {
    required String peerId,
  });

  /// Live events for an open chat: read receipts, typing, incoming and
  /// deleted messages (from the viewer's realtime topic). The live connection
  /// is held open only while this stream has a listener.
  Stream<ChatIncomingEvent> chatEvents(String conversationId);

  /// Live "new message" pings for the inbox list. The live connection is held
  /// open only while this stream has a listener.
  Stream<InboxLiveEvent> inboxEvents();

  /// Users the viewer can start a new conversation with (compose sheet).
  Future<Either<Failure, List<MessageUserEntity>>> getComposeSuggestions(
    String query,
  );
}
