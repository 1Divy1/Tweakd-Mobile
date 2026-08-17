import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/feedback_message.dart';
import '../repositories/feedback_feed_repository.dart';

class CreateFeedbackMessageParams {
  final String typeId;
  final String message;

  const CreateFeedbackMessageParams({
    required this.typeId,
    required this.message,
  });
}

/// Publishes a new message to the board.
@lazySingleton
class CreateFeedbackMessageUseCase
    implements UseCase<Unit, CreateFeedbackMessageParams> {
  final FeedbackFeedRepository repository;

  CreateFeedbackMessageUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(
    CreateFeedbackMessageParams params,
  ) {
    return repository.createMessage(
      typeId: params.typeId,
      message: params.message,
    );
  }
}

class FeedbackMessageIdParams {
  final String messageId;
  const FeedbackMessageIdParams(this.messageId);
}

/// Hard-deletes the caller's own message — only possible while it is `sent`.
@lazySingleton
class DeleteFeedbackMessageUseCase
    implements UseCase<Unit, FeedbackMessageIdParams> {
  final FeedbackFeedRepository repository;

  DeleteFeedbackMessageUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(FeedbackMessageIdParams params) {
    return repository.deleteMessage(params.messageId);
  }
}

/// Fetches a single card with the caller's vote resolved.
@lazySingleton
class GetFeedbackMessageUseCase
    implements UseCase<FeedbackMessageEntity, FeedbackMessageIdParams> {
  final FeedbackFeedRepository repository;

  GetFeedbackMessageUseCase(this.repository);

  @override
  Future<Either<Failure, FeedbackMessageEntity>> call(
    FeedbackMessageIdParams params,
  ) {
    return repository.getMessage(params.messageId);
  }
}
