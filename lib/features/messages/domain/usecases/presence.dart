import 'package:injectable/injectable.dart';

import '../entities/presence.dart';
import '../repositories/messages_repository.dart';

/// Who of these users is online right now. Synchronous and infallible: it
/// reads the global presence channel's current state, so there is no request
/// to fail and no Either to fold.
@lazySingleton
class GetPresenceUseCase {
  final MessagesRepository repository;

  GetPresenceUseCase(this.repository);

  List<PresenceEntity> call(List<String> userIds) =>
      repository.getPresence(userIds);
}

/// Live presence flips from the global presence channel. Stream-based, so it
/// doesn't fit the Either [UseCase] shape (same as WatchChatUseCase).
@lazySingleton
class WatchPresenceUseCase {
  final MessagesRepository repository;

  WatchPresenceUseCase(this.repository);

  Stream<PresenceEntity> call() => repository.presenceUpdates();
}
