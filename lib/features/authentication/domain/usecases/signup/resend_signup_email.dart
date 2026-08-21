import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/base_failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../repositories/auth_repository.dart';

@lazySingleton
class ResendSignUpEmail implements UseCase<Unit, String> {
  final AuthRepository repository;

  ResendSignUpEmail(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String email) async {
    return await repository.resendSignUpEmail(email);
  }
}
