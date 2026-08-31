import 'package:tweakd/core/usecases/usecase.dart';
import 'package:tweakd/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/base_failures.dart';
import '../../entities/apple_sign_in_result.dart';

@lazySingleton
class AppleSignIn implements UseCase<AppleSignInResultEntity, NoParams> {
  final AuthRepository repository;

  AppleSignIn(this.repository);

  @override
  Future<Either<Failure, AppleSignInResultEntity>> call(NoParams params) async {
    return await repository.appleSignIn();
  }
}
