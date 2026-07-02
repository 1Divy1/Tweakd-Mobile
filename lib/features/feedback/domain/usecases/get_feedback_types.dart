import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/feedback_type.dart';
import '../repositories/feedback_repository.dart';

@lazySingleton
class GetFeedbackTypesUseCase
    implements UseCase<List<FeedbackTypeEntity>, NoParams> {
  final FeedbackRepository repository;

  GetFeedbackTypesUseCase(this.repository);

  @override
  Future<Either<Failure, List<FeedbackTypeEntity>>> call(NoParams params) {
    return repository.getTypes();
  }
}
