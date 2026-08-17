import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/feedback_option.dart';
import '../repositories/feedback_feed_repository.dart';

/// The categories shown on the compose screen.
@lazySingleton
class GetFeedbackTypesUseCase
    implements UseCase<List<FeedbackOptionEntity>, NoParams> {
  final FeedbackFeedRepository repository;

  GetFeedbackTypesUseCase(this.repository);

  @override
  Future<Either<Failure, List<FeedbackOptionEntity>>> call(NoParams params) {
    return repository.getTypes();
  }
}

/// The roadmap stages, in order. Wired for completeness — no screen consumes it
/// yet, since only staff can move a message along the roadmap.
@lazySingleton
class GetFeedbackStatusesUseCase
    implements UseCase<List<FeedbackOptionEntity>, NoParams> {
  final FeedbackFeedRepository repository;

  GetFeedbackStatusesUseCase(this.repository);

  @override
  Future<Either<Failure, List<FeedbackOptionEntity>>> call(NoParams params) {
    return repository.getStatuses();
  }
}
