import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chat.dart';
import '../repositories/messages_repository.dart';

@lazySingleton
class GetChatUseCase implements UseCase<ChatEntity, String> {
  final MessagesRepository repository;

  GetChatUseCase(this.repository);

  @override
  Future<Either<Failure, ChatEntity>> call(String conversationId) =>
      repository.getChat(conversationId);
}
