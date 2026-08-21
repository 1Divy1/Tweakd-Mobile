import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/base_failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

/// Step 3 of the reset: sets the new password on the recovery session.
@lazySingleton
class UpdatePassword implements UseCase<UserEntity, String> {
  final AuthRepository repository;

  UpdatePassword(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(String newPassword) async {
    return await repository.updatePassword(newPassword);
  }
}
