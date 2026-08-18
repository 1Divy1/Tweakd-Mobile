import 'package:dartz/dartz.dart';

import '../../../../core/error/base_failures.dart';
import '../entities/feedback_message.dart';
import '../entities/feedback_option.dart';
import '../entities/feedback_sort.dart';

abstract class FeedbackFeedRepository {
  /// The categories offered on the compose screen.
  Future<Either<Failure, List<FeedbackOptionEntity>>> getTypes();

  /// The roadmap stages, in order. No UI consumes this yet — users can't move a
  /// message along the roadmap and the board has no status filter — but it is
  /// wired end to end so a future screen can use it.
  Future<Either<Failure, List<FeedbackOptionEntity>>> getStatuses();

  /// The main board. Excludes completed messages (they live on their own
  /// screen).
  Future<Either<Failure, FeedbackMessagePageEntity>> getFeed({
    required FeedbackSort sort,
    String? cursor,
    int size,
  });

  /// Completed requests, most recently shipped first.
  Future<Either<Failure, FeedbackMessagePageEntity>> getCompleted({
    String? cursor,
    int size,
  });

  Future<Either<Failure, FeedbackMessageEntity>> getMessage(String messageId);

  /// Publishes a message. The created card isn't returned — the board refetches
  /// instead, so the response body is never relied on (see the data source).
  Future<Either<Failure, Unit>> createMessage({
    required String typeId,
    required String message,
  });

  /// Hard-deletes the caller's own message. Fails with
  /// [FeedbackMessageLockedFailure] once the status has moved past `sent`.
  Future<Either<Failure, Unit>> deleteMessage(String messageId);

  /// Casts a vote (`1` up / `-1` down) and returns the updated card.
  Future<Either<Failure, FeedbackMessageEntity>> vote({
    required String messageId,
    required int value,
  });

  /// Withdraws the caller's vote. Idempotent.
  Future<Either<Failure, FeedbackMessageEntity>> withdrawVote(String messageId);
}
