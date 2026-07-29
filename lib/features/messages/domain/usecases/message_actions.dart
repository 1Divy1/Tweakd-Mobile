import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/messages_repository.dart';

/// Soft-deletes the viewer's own message. Params = message id.
@lazySingleton
class DeleteMessageUseCase implements UseCase<void, String> {
  final MessagesRepository repository;

  DeleteMessageUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String messageId) =>
      repository.deleteMessage(messageId);
}

/// Hides a conversation from the viewer's list. Params = conversation id.
@lazySingleton
class HideConversationUseCase implements UseCase<void, String> {
  final MessagesRepository repository;

  HideConversationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String conversationId) =>
      repository.hideConversation(conversationId);
}

/// Marks a conversation read up to its latest message. Params =
/// conversation id.
@lazySingleton
class MarkConversationReadUseCase implements UseCase<void, String> {
  final MessagesRepository repository;

  MarkConversationReadUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String conversationId) =>
      repository.markConversationRead(conversationId);
}

/// Fire-and-forget typing signal — not the Either [UseCase] shape because
/// there is no result to fold; callers throttle.
@lazySingleton
class SendTypingUseCase {
  final MessagesRepository repository;

  SendTypingUseCase(this.repository);

  void call(String conversationId, {required bool isTyping}) =>
      repository.sendTyping(conversationId, isTyping);
}
