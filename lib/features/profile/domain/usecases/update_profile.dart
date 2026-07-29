import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

/// [name] / [bio]: `null` = leave unchanged, `''` = clear, any other value =
/// set. The caller (bloc) diffs against the original profile before deciding.
class UpdateProfileParams {
  final String? name;
  final String? bio;

  const UpdateProfileParams({this.name, this.bio});
}

@lazySingleton
class UpdateProfileUseCase implements UseCase<ProfileEntity, UpdateProfileParams> {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, ProfileEntity>> call(UpdateProfileParams params) {
    return repository.updateProfile(name: params.name, bio: params.bio);
  }
}
