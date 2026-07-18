import 'package:dartz/dartz.dart';

import '../../../../core/error/base_failures.dart';
import '../entities/chat.dart';
import '../entities/chat_events.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';
import '../entities/message_user.dart';
import '../entities/presence.dart';

abstract class MessagesRepository {
  /// One keyset page of the inbox (most recently active first).
  /// Pass the previous page's cursor to fetch the next one.
  Future<Either<Failure, InboxEntity>> getInbox({String? cursor});

  /// One keyset page of a conversation's history, oldest-first.
  Future<Either<Failure, MessagesPageEntity>> getMessages(
    String conversationId, {
    String? cursor,
  });

  /// Sends a DM addressed by recipient — the first message between two users
  /// creates the conversation implicitly (its id is in the result).
  /// [taggedCarIds] shares cars from the sender's garage; [text] may be blank
  /// when at least one car is attached.
  Future<Either<Failure, SentMessageEntity>> sendMessage(
    String recipientId,
    String text, {
    List<String> taggedCarIds,
  });

  /// Soft-deletes the viewer's own message (idempotent server-side).
  Future<Either<Failure, void>> deleteMessage(String messageId);

  /// Hides ("deletes") a conversation from the viewer's list only.
  Future<Either<Failure, void>> hideConversation(String conversationId);

  /// Marks the conversation read up to its latest message; the peer gets a
  /// conversation.read push.
  Future<Either<Failure, void>> markConversationRead(String conversationId);

  /// Total unread messages across all conversations (app-level DMs badge).
  Future<Either<Failure, int>> getUnreadCount();

  /// Fire-and-forget typing signal over the socket (throttled by callers).
  void sendTyping(String conversationId, bool isTyping);

  /// Live events for an open chat: read receipts, typing, incoming and
  /// deleted messages (mapped from the app-wide DM socket).
  Stream<ChatIncomingEvent> chatEvents(String conversationId);

  /// Live "new message" pings for the inbox list.
  Stream<InboxMessageEvent> inboxMessageEvents();

  /// Users the viewer can start a new conversation with (compose sheet).
  Future<Either<Failure, List<MessageUserEntity>>> getComposeSuggestions(
    String query,
  );

  /// Batch presence lookup (chat header on open, profile pages later).
  Future<Either<Failure, List<PresenceEntity>>> getPresence(
    List<String> userIds,
  );

  /// Live presence flips for users the viewer shares a conversation with,
  /// pushed over the app-wide DM socket.
  Stream<PresenceEntity> presenceUpdates();
}
