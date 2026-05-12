import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class GetCurrentUserParams {
  final bool fetchFromRemote;

  const GetCurrentUserParams({this.fetchFromRemote = false});
}

@lazySingleton
class GetCurrentUserProfileUseCase
    implements UseCase<ProfileEntity, GetCurrentUserParams> {
  final ProfileRepository repository;

  GetCurrentUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, ProfileEntity>> call(GetCurrentUserParams params) {
    return repository.getCurrentUserProfile(forceRefresh: params.fetchFromRemote);
  }
}
