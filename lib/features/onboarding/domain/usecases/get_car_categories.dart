import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/onboarding reference/car_category_entity.dart';
import '../repositories/onboarding_repository.dart';

@lazySingleton
class GetCarCategoriesUseCase
    implements UseCase<List<CarCategoryEntity>, NoParams> {
  final OnboardingRepository repository;

  GetCarCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<CarCategoryEntity>>> call(NoParams _) =>
      repository.getCarCategories();
}
