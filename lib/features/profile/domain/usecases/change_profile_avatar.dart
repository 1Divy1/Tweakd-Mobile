import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class ChangeProfileAvatarParams {
  /// Local file path of the picked image (converted to WebP by the repository).
  final String imagePath;

  const ChangeProfileAvatarParams({required this.imagePath});
}

/// Thin wrapper over the repository's 3-step avatar pipeline
/// (slot → WebP → presigned PUT → commit key).
@lazySingleton
class ChangeProfileAvatarUseCase implements UseCase<ProfileEntity, ChangeProfileAvatarParams> {
  final ProfileRepository repository;

  ChangeProfileAvatarUseCase(this.repository);

  @override
  Future<Either<Failure, ProfileEntity>> call(
    ChangeProfileAvatarParams params,
  ) {
    return repository.changeAvatar(params.imagePath);
  }
}
