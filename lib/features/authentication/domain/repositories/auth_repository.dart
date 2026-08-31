import 'package:dartz/dartz.dart';

import '../../../../core/error/base_failures.dart';
import '../entities/apple_sign_in_result.dart';
import '../entities/sign_up_result.dart';
import '../entities/user.dart';
import '../usecases/login/email_password_signin.dart';
import '../usecases/password_reset/verify_password_reset_code.dart';
import '../usecases/signup/email_password_signup.dart';
import '../usecases/signup/verify_signup_code.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> checkAuthStatus();
  Future<Either<Failure, UserEntity>> emailPasswordSignIn(LoginParams params);
  Future<Either<Failure, UserEntity>> googleSignIn();

  /// Signs in with Apple. See [AppleSignInResultEntity] for the two shapes the
  /// success case can take — iOS resolves a user, Android only launches the
  /// browser and reports back that a redirect is pending.
  Future<Either<Failure, AppleSignInResultEntity>> appleSignIn();
  Future<Either<Failure, Unit>> logOut();

  /// Registers a new account. See [SignUpResultEntity] for the two shapes the
  /// success case can take.
  Future<Either<Failure, SignUpResultEntity>> signUp(SignUpParams params);

  /// Confirms a new account with the code from the sign-up email;
  /// the user is signed in on success.
  Future<Either<Failure, UserEntity>> verifySignUpCode(
    VerifySignUpCodeParams params,
  );

  /// Re-sends the confirmation email for an unverified account.
  Future<Either<Failure, Unit>> resendSignUpEmail(String email);

  /// Password reset, step 1 — emails a recovery code.
  Future<Either<Failure, Unit>> requestPasswordReset(String email);

  /// Password reset, step 2 — exchanges the code for a recovery session.
  Future<Either<Failure, Unit>> verifyPasswordResetCode(
    VerifyPasswordResetCodeParams params,
  );

  /// Password reset, step 3 — sets the new password on the recovery session.
  Future<Either<Failure, UserEntity>> updatePassword(String newPassword);

  /// Emits when a session appears without the app asking for one — i.e. the
  /// confirmation deep link was opened and the SDK completed the exchange.
  Stream<void> get onExternalSignIn;
}
