import 'package:injectable/injectable.dart';

import '../entities/conversation.dart';
import '../repositories/messages_repository.dart';

/// Live "new message" pings for the inbox list. Stream-based, so it doesn't
/// fit the Either [UseCase] shape (same as WatchChatUseCase).
@lazySingleton
class WatchInboxMessagesUseCase {
  final MessagesRepository repository;

  WatchInboxMessagesUseCase(this.repository);

  Stream<InboxMessageEvent> call() => repository.inboxMessageEvents();
}
