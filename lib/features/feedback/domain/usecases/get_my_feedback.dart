import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/my_feedback.dart';
import '../repositories/feedback_repository.dart';

@lazySingleton
class GetMyFeedbackUseCase
    implements UseCase<List<MyFeedbackEntity>, NoParams> {
  final FeedbackRepository repository;

  GetMyFeedbackUseCase(this.repository);

  @override
  Future<Either<Failure, List<MyFeedbackEntity>>> call(NoParams params) {
    return repository.getMyFeedback();
  }
}
