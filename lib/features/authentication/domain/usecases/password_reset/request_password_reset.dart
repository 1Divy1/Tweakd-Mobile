import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/base_failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../repositories/auth_repository.dart';

/// Step 1 of the reset: emails a recovery code.
@lazySingleton
class RequestPasswordReset implements UseCase<Unit, String> {
  final AuthRepository repository;

  RequestPasswordReset(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String email) async {
    return await repository.requestPasswordReset(email);
  }
}
