import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class GetProfileByUsernameParams {
  final String username;
  const GetProfileByUsernameParams({required this.username});
}

@lazySingleton
class GetProfileByUsernameUseCase
    implements UseCase<ProfileEntity, GetProfileByUsernameParams> {
  final ProfileRepository repository;

  GetProfileByUsernameUseCase(this.repository);

  @override
  Future<Either<Failure, ProfileEntity>> call(
    GetProfileByUsernameParams params,
  ) {
    return repository.getProfileByUsername(params.username);
  }
}
