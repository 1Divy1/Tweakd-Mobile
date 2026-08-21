import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/base_failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../entities/sign_up_result.dart';
import '../../repositories/auth_repository.dart';

class SignUpParams {
  final String email;
  final String password;

  SignUpParams({required this.email, required this.password});
}

@lazySingleton
class EmailPasswordSignUp implements UseCase<SignUpResultEntity, SignUpParams> {
  final AuthRepository repository;

  EmailPasswordSignUp(this.repository);

  @override
  Future<Either<Failure, SignUpResultEntity>> call(SignUpParams params) async {
    return await repository.signUp(params);
  }
}
