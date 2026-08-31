import 'package:tweakd/core/error/base_failures.dart';
import 'package:tweakd/core/usecases/usecase.dart';
import 'package:tweakd/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../entities/user.dart';

@lazySingleton
class CheckAuthStatusUseCase implements UseCase<UserEntity, NoParams> {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) async {
    return await repository.checkAuthStatus();
  }
}