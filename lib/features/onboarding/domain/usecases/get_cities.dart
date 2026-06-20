import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/onboarding reference/city_entity.dart';
import '../repositories/onboarding_repository.dart';

class GetCitiesParams {
  final String countryId;
  const GetCitiesParams({required this.countryId});
}

@lazySingleton
class GetCitiesUseCase implements UseCase<List<CityEntity>, GetCitiesParams> {
  final OnboardingRepository repository;

  GetCitiesUseCase(this.repository);

  @override
  Future<Either<Failure, List<CityEntity>>> call(GetCitiesParams params) =>
      repository.getCities(params.countryId);
}
