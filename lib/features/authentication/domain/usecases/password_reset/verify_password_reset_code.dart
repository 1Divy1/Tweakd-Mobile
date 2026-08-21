import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/base_failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../repositories/auth_repository.dart';

class VerifyPasswordResetCodeParams {
  final String email;
  final String code;

  VerifyPasswordResetCodeParams({required this.email, required this.code});
}

/// Step 2 of the reset: exchanges the emailed code for a recovery session.
@lazySingleton
class VerifyPasswordResetCode
    implements UseCase<Unit, VerifyPasswordResetCodeParams> {
  final AuthRepository repository;

  VerifyPasswordResetCode(this.repository);

  @override
  Future<Either<Failure, Unit>> call(
    VerifyPasswordResetCodeParams params,
  ) async {
    return await repository.verifyPasswordResetCode(params);
  }
}
