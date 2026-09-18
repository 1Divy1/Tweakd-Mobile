import 'package:tweakd/core/usecases/usecase.dart';
import 'package:tweakd/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/base_failures.dart';
import '../../entities/apple_sign_in_result.dart';
import '../../entities/social_auth_intent.dart';

@lazySingleton
class AppleSignIn
    implements UseCase<AppleSignInResultEntity, SocialAuthIntent> {
  final AuthRepository repository;

  AppleSignIn(this.repository);

  @override
  Future<Either<Failure, AppleSignInResultEntity>> call(
    SocialAuthIntent intent,
  ) async {
    return await repository.appleSignIn(intent);
  }
}
