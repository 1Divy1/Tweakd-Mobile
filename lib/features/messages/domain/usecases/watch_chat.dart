import 'package:injectable/injectable.dart';

import '../entities/chat_events.dart';
import '../repositories/messages_repository.dart';

/// Live chat events (read receipts, typing, incoming messages) for an open
/// conversation. Stream-based, so it doesn't fit the Either [UseCase] shape.
/// Listening holds the live connection open.
@lazySingleton
class WatchChatUseCase {
  final MessagesRepository repository;

  WatchChatUseCase(this.repository);

  Stream<ChatIncomingEvent> call(String conversationId) =>
      repository.chatEvents(conversationId);
}
