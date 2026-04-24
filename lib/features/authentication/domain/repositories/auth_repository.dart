import 'package:dartz/dartz.dart';

import '../../../../core/error/base_failures.dart';
import '../entities/user.dart';
import '../usecases/login/email_password_signin.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> checkAuthStatus();
  Future<Either<Failure, UserEntity>> emailPasswordSignIn(LoginParams params);
  Future<Either<Failure, UserEntity>> googleSignIn();
  Future<Either<Failure, void>> updateUsername(String username);
}