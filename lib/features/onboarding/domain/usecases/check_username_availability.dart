import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/onboarding_repository.dart';

class CheckUsernameAvailabilityParams {
  final String username;
  final CancelToken? cancelToken;

  const CheckUsernameAvailabilityParams({
    required this.username,
    this.cancelToken,
  });
}

/// Resolves whether a handle is still free. `true` means available, `false`
/// means already taken.
@lazySingleton
class CheckUsernameAvailabilityUseCase
    implements UseCase<bool, CheckUsernameAvailabilityParams> {
  final OnboardingRepository repository;

  CheckUsernameAvailabilityUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(CheckUsernameAvailabilityParams params) {
    return repository.checkUsernameAvailable(
      params.username,
      cancelToken: params.cancelToken,
    );
  }
}
