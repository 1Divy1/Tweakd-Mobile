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

  /// Cars shared from the sender's garage (max 10). [text] may be blank when
  /// this is non-empty. Full entities rather than ids: only the ids reach the
  /// database, but the cover images ride along in the broadcast that renders
  /// the peer's copy of the message.
  final List<DmTaggedCarEntity> taggedCars;

  const SendMessageParams({
    required this.recipientId,
    required this.text,
    this.taggedCars = const [],
  });

  @override
  List<Object?> get props => [recipientId, text, taggedCars];
}

@lazySingleton
class SendMessageUseCase
    implements UseCase<SentMessageEntity, SendMessageParams> {
  final MessagesRepository repository;

  SendMessageUseCase(this.repository);

  @override
  Future<Either<Failure, SentMessageEntity>> call(SendMessageParams params) =>
      repository.sendMessage(
        params.recipientId,
        params.text,
        taggedCars: params.taggedCars,
      );
}
