import 'package:injectable/injectable.dart';

import '../entities/conversation.dart';
import '../repositories/messages_repository.dart';

/// Live updates for the inbox list: "new message" pings, and a reconnect
/// signal to refetch on. Stream-based, so it doesn't fit the Either [UseCase]
/// shape (same as WatchChatUseCase). Listening holds the live connection open.
@lazySingleton
class WatchInboxMessagesUseCase {
  final MessagesRepository repository;

  WatchInboxMessagesUseCase(this.repository);

  Stream<InboxLiveEvent> call() => repository.inboxEvents();
}
