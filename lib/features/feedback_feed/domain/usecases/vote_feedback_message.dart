import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/feedback_message.dart';
import '../repositories/feedback_feed_repository.dart';

class VoteFeedbackMessageParams {
  final String messageId;

  /// `1` for an up vote, `-1` for a down vote.
  final int value;

  const VoteFeedbackMessageParams({
    required this.messageId,
    required this.value,
  });
}

/// Casts (or switches) a vote. Both calls return the updated card, so the bloc
/// can reconcile its optimistic numbers with the server's.
@lazySingleton
class VoteFeedbackMessageUseCase
    implements UseCase<FeedbackMessageEntity, VoteFeedbackMessageParams> {
  final FeedbackFeedRepository repository;

  VoteFeedbackMessageUseCase(this.repository);

  @override
  Future<Either<Failure, FeedbackMessageEntity>> call(
    VoteFeedbackMessageParams params,
  ) {
    return repository.vote(
      messageId: params.messageId,
      value: params.value,
    );
  }
}

class WithdrawFeedbackVoteParams {
  final String messageId;
  const WithdrawFeedbackVoteParams(this.messageId);
}

/// Withdraws the caller's vote (tapping the arrow they already picked).
@lazySingleton
class WithdrawFeedbackVoteUseCase
    implements UseCase<FeedbackMessageEntity, WithdrawFeedbackVoteParams> {
  final FeedbackFeedRepository repository;

  WithdrawFeedbackVoteUseCase(this.repository);

  @override
  Future<Either<Failure, FeedbackMessageEntity>> call(
    WithdrawFeedbackVoteParams params,
  ) {
    return repository.withdrawVote(params.messageId);
  }
}
