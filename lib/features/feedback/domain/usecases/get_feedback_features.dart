import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/feedback_feature.dart';
import '../repositories/feedback_repository.dart';

@lazySingleton
class GetFeedbackFeaturesUseCase
    implements UseCase<List<FeedbackFeatureEntity>, NoParams> {
  final FeedbackRepository repository;

  GetFeedbackFeaturesUseCase(this.repository);

  @override
  Future<Either<Failure, List<FeedbackFeatureEntity>>> call(NoParams params) {
    return repository.getFeatures();
  }
}
