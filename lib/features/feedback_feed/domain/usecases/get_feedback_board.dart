import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/feedback_message.dart';
import '../entities/feedback_sort.dart';
import '../repositories/feedback_feed_repository.dart';

class GetFeedbackBoardParams {
  final FeedbackSort sort;
  final String? cursor;
  final int size;

  const GetFeedbackBoardParams({
    this.sort = FeedbackSort.newest,
    this.cursor,
    this.size = 20,
  });
}

/// The main board (everything except completed messages), in the chosen order.
@lazySingleton
class GetFeedbackBoardUseCase
    implements UseCase<FeedbackMessagePageEntity, GetFeedbackBoardParams> {
  final FeedbackFeedRepository repository;

  GetFeedbackBoardUseCase(this.repository);

  @override
  Future<Either<Failure, FeedbackMessagePageEntity>> call(
    GetFeedbackBoardParams params,
  ) {
    return repository.getFeed(
      sort: params.sort,
      cursor: params.cursor,
      size: params.size,
    );
  }
}

class GetCompletedFeedbackParams {
  final String? cursor;
  final int size;

  const GetCompletedFeedbackParams({this.cursor, this.size = 20});
}

/// The completed-requests screen, most recently shipped first.
@lazySingleton
class GetCompletedFeedbackUseCase
    implements UseCase<FeedbackMessagePageEntity, GetCompletedFeedbackParams> {
  final FeedbackFeedRepository repository;

  GetCompletedFeedbackUseCase(this.repository);

  @override
  Future<Either<Failure, FeedbackMessagePageEntity>> call(
    GetCompletedFeedbackParams params,
  ) {
    return repository.getCompleted(cursor: params.cursor, size: params.size);
  }
}
