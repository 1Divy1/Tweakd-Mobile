import 'package:tweakd/core/usecases/usecase.dart';
import 'package:tweakd/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/base_failures.dart';
import '../../entities/social_auth_intent.dart';
import '../../entities/user.dart';

@lazySingleton
class GoogleSignIn implements UseCase<UserEntity, SocialAuthIntent> {
  final AuthRepository repository;

  GoogleSignIn(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SocialAuthIntent intent) async {
    return await repository.googleSignIn(intent);
  }
}
