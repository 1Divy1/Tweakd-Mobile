import 'package:tweakd/features/profile/domain/entities/profile.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/onboarding_repository.dart';

@lazySingleton
class SubmitOnboardingUseCase
    implements UseCase<ProfileEntity, OnboardingSubmissionParams> {
  final OnboardingRepository repository;

  SubmitOnboardingUseCase(this.repository);

  @override
  Future<Either<Failure, ProfileEntity>> call(
          OnboardingSubmissionParams params) =>
      repository.submitOnboarding(params);
}
