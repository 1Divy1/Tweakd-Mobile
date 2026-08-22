import 'package:tweakd/core/usecases/usecase.dart';
import 'package:tweakd/features/authentication/domain/entities/user.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/base_failures.dart';
import '../../repositories/auth_repository.dart';

class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}

@lazySingleton
class EmailPasswordSignIn implements UseCase<UserEntity, LoginParams> {
  final AuthRepository repository;

  EmailPasswordSignIn(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) async {
    return await repository.emailPasswordSignIn(params);
  }
}