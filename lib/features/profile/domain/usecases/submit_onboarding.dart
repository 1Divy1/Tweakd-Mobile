import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class SubmitOnboardingParams {
  final String username;
  final String? bio;

  const SubmitOnboardingParams({required this.username, this.bio});
}

@lazySingleton
class SubmitOnboardingUseCase
    implements UseCase<ProfileEntity, SubmitOnboardingParams> {
  final ProfileRepository repository;

  SubmitOnboardingUseCase(this.repository);

  @override
  Future<Either<Failure, ProfileEntity>> call(SubmitOnboardingParams params) {
    return repository.submitOnboarding(
      username: params.username,
      bio: params.bio,
    );
  }
}
