import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message_user.dart';
import '../repositories/messages_repository.dart';

/// Resolves the peer of a conversation known only by id.
///
/// The chat header needs a full user (avatar, verified badge), and every
/// in-app path into a chat already carries one. A push notification tap does
/// not: its payload names the conversation and the sender's username, but no
/// avatar. This fills the gap so a tapped DM opens the real conversation
/// instead of bouncing to the inbox.
@lazySingleton
class GetConversationPeerUseCase implements UseCase<MessageUserEntity, String> {
  final MessagesRepository repository;

  GetConversationPeerUseCase(this.repository);

  @override
  Future<Either<Failure, MessageUserEntity>> call(String conversationId) =>
      repository.getConversationPeer(conversationId);
}
