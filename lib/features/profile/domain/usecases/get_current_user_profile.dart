import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

@lazySingleton
class GetCurrentUserProfileUseCase
    implements UseCase<ProfileEntity, NoParams> {
  final ProfileRepository repository;

  GetCurrentUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, ProfileEntity>> call(NoParams params) {
    return repository.getCurrentUserProfile();
  }
}
