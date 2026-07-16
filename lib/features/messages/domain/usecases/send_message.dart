import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message.dart';
import '../repositories/messages_repository.dart';

/// Addressed by recipient, not conversation — the first message between two
/// users creates the conversation implicitly.
class SendMessageParams extends Equatable {
  final String recipientId;
  final String text;

  const SendMessageParams({required this.recipientId, required this.text});

  @override
  List<Object?> get props => [recipientId, text];
}

@lazySingleton
class SendMessageUseCase
    implements UseCase<SentMessageEntity, SendMessageParams> {
  final MessagesRepository repository;

  SendMessageUseCase(this.repository);

  @override
  Future<Either<Failure, SentMessageEntity>> call(SendMessageParams params) =>
      repository.sendMessage(params.recipientId, params.text);
}
