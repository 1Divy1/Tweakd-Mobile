import 'package:tweakd/core/usecases/usecase.dart';
import 'package:tweakd/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/base_failures.dart';
import '../../entities/social_auth_intent.dart';
import '../../entities/user.dart';

/// Finishes a social sign-in whose session arrived on its own — the Android
/// Apple flow, which returns through a deep link after [AppleSignIn] has
/// already returned. Applies the same sign-in / sign-up rules the in-process
/// flows apply before they return.
@lazySingleton
class CompleteSocialSignIn implements UseCase<UserEntity, SocialAuthIntent> {
  final AuthRepository repository;

  CompleteSocialSignIn(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SocialAuthIntent intent) async {
    return await repository.completeSocialSignIn(intent);
  }
}
