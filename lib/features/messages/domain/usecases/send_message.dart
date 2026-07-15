import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message.dart';
import '../repositories/messages_repository.dart';

class SendMessageParams extends Equatable {
  final String conversationId;
  final String text;

  const SendMessageParams({required this.conversationId, required this.text});

  @override
  List<Object?> get props => [conversationId, text];
}

@lazySingleton
class SendMessageUseCase implements UseCase<MessageEntity, SendMessageParams> {
  final MessagesRepository repository;

  SendMessageUseCase(this.repository);

  @override
  Future<Either<Failure, MessageEntity>> call(SendMessageParams params) =>
      repository.sendMessage(params.conversationId, params.text);
}
