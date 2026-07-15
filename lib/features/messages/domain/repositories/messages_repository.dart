import 'package:dartz/dartz.dart';

import '../../../../core/error/base_failures.dart';
import '../entities/chat.dart';
import '../entities/chat_events.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';
import '../entities/message_user.dart';

abstract class MessagesRepository {
  /// Inbox: active-now users, message-requests summary and conversations.
  Future<Either<Failure, InboxEntity>> getInbox();

  /// Loads a chat and marks its incoming messages as read.
  Future<Either<Failure, ChatEntity>> getChat(String conversationId);

  /// Sends a text message; resolves with the persisted message.
  Future<Either<Failure, MessageEntity>> sendMessage(
    String conversationId,
    String text,
  );

  /// Live events for an open chat: read receipts, typing, incoming messages.
  Stream<ChatIncomingEvent> chatEvents(String conversationId);

  /// Users the viewer can start a new conversation with (compose sheet).
  Future<Either<Failure, List<MessageUserEntity>>> getComposeSuggestions(
    String query,
  );

  /// Opens (or creates) the conversation with [userId]; returns its id.
  Future<Either<Failure, String>> startConversation(String userId);
}
