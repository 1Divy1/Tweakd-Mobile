import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/onboarding reference/country_entity.dart';
import '../repositories/onboarding_repository.dart';

@lazySingleton
class GetCountriesUseCase implements UseCase<List<CountryEntity>, NoParams> {
  final OnboardingRepository repository;

  GetCountriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<CountryEntity>>> call(NoParams _) =>
      repository.getCountries();
}
