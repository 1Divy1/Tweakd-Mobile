import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/base_failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

/// The signed-in, onboarded user as the device remembers them — no network.
/// Resolves to null whenever that can't be vouched for locally (no session, or
/// onboarding not known to be complete), in which case the caller has to fall
/// back to [CheckAuthStatusUseCase].
@lazySingleton
class GetCachedAuthStatusUseCase implements UseCase<UserEntity?, NoParams> {
  final AuthRepository repository;

  GetCachedAuthStatusUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) async =>
      Right(await repository.getCachedAuthStatus());
}
