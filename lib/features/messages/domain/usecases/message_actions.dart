import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/messages_repository.dart';

/// Actions that also notify the peer carry [peerId]: every live update is a
/// broadcast this client publishes right after its own write succeeds, so the
/// peer's topic has to be named at the call site.
class DeleteMessageParams extends Equatable {
  final String messageId;
  final String conversationId;
  final String peerId;

  const DeleteMessageParams({
    required this.messageId,
    required this.conversationId,
    required this.peerId,
  });

  @override
  List<Object?> get props => [messageId, conversationId, peerId];
}

/// Soft-deletes the viewer's own message and tells the peer.
@lazySingleton
class DeleteMessageUseCase implements UseCase<void, DeleteMessageParams> {
  final MessagesRepository repository;

  DeleteMessageUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteMessageParams params) =>
      repository.deleteMessage(
        params.messageId,
        conversationId: params.conversationId,
        peerId: params.peerId,
      );
}

/// Hides a conversation from the viewer's list. Params = conversation id.
/// Caller-side only, so the peer is never told.
@lazySingleton
class HideConversationUseCase implements UseCase<void, String> {
  final MessagesRepository repository;

  HideConversationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String conversationId) =>
      repository.hideConversation(conversationId);
}

class MarkConversationReadParams extends Equatable {
  final String conversationId;
  final String peerId;

  const MarkConversationReadParams({
    required this.conversationId,
    required this.peerId,
  });

  @override
  List<Object?> get props => [conversationId, peerId];
}

/// Marks a conversation read up to its latest message and pushes the new
/// watermark to the peer so their messages flip to "Seen".
@lazySingleton
class MarkConversationReadUseCase
    implements UseCase<void, MarkConversationReadParams> {
  final MessagesRepository repository;

  MarkConversationReadUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(MarkConversationReadParams params) =>
      repository.markConversationRead(
        params.conversationId,
        peerId: params.peerId,
      );
}

/// Fire-and-forget typing signal — not the Either [UseCase] shape because
/// there is no result to fold; callers throttle.
@lazySingleton
class SendTypingUseCase {
  final MessagesRepository repository;

  SendTypingUseCase(this.repository);

  void call(
    String conversationId, {
    required bool isTyping,
    required String peerId,
  }) =>
      repository.sendTyping(conversationId, isTyping, peerId: peerId);
}
