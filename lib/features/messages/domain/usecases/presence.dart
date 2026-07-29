import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/presence.dart';
import '../repositories/messages_repository.dart';

/// Batch presence lookup — `GET /presence?user_ids=…`.
@lazySingleton
class GetPresenceUseCase implements UseCase<List<PresenceEntity>, List<String>> {
  final MessagesRepository repository;

  GetPresenceUseCase(this.repository);

  @override
  Future<Either<Failure, List<PresenceEntity>>> call(List<String> userIds) =>
      repository.getPresence(userIds);
}

/// Live presence flips from the DM socket. Stream-based, so it doesn't fit
/// the Either [UseCase] shape (same as WatchChatUseCase).
@lazySingleton
class WatchPresenceUseCase {
  final MessagesRepository repository;

  WatchPresenceUseCase(this.repository);

  Stream<PresenceEntity> call() => repository.presenceUpdates();
}
