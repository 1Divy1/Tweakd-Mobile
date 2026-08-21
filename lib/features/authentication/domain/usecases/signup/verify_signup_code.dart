import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/base_failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class VerifySignUpCodeParams {
  final String email;
  final String code;

  VerifySignUpCodeParams({required this.email, required this.code});
}

/// Confirms a new account with the code from the sign-up email. On
/// success the user is signed in, so the result carries the resolved user.
@lazySingleton
class VerifySignUpCode implements UseCase<UserEntity, VerifySignUpCodeParams> {
  final AuthRepository repository;

  VerifySignUpCode(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(
    VerifySignUpCodeParams params,
  ) async {
    return await repository.verifySignUpCode(params);
  }
}
