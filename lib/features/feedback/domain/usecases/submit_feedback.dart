import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/feedback_repository.dart';

@lazySingleton
class SubmitFeedbackUseCase implements UseCase<void, FeedbackSubmission> {
  final FeedbackRepository repository;

  SubmitFeedbackUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(FeedbackSubmission params) {
    return repository.submitFeedback(params);
  }
}
