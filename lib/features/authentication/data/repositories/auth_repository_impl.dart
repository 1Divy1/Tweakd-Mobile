import 'package:car_social_media_app/features/authentication/data/datasources/supabase_auth_data_source.dart';
import 'package:car_social_media_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/error/base_failures.dart';
import '../exceptions/auth_exceptions.dart';
import '../../domain/failures/auth_failures.dart';
import '../../domain/entities/sign_up_result.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login/email_password_signin.dart';
import '../../domain/usecases/password_reset/verify_password_reset_code.dart';
import '../../domain/usecases/signup/email_password_signup.dart';
import '../../domain/usecases/signup/verify_signup_code.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseAuthDataSource supabaseDataSource;

  AuthRepositoryImpl(this.supabaseDataSource);

  /// Single exception → failure table for every auth path. Kept in one place so
  /// a new call site cannot accidentally collapse a specific error (a wrong
  /// code, a rate limit) into the generic "something went wrong".
  Failure _toFailure(Object error) {
    switch (error) {
      case NoActiveSessionException e:
        return UnauthenticatedFailure(e.message);
      case UnauthenticatedException e:
        return UnauthenticatedFailure(e.message);
      case InvalidCredentialsException e:
        return InvalidCredentialsFailure(e.message);
      case EmailNotConfirmedException e:
        return EmailNotConfirmedFailure(e.message);
      case WeakPasswordException e:
        return WeakPasswordFailure(e.message);
      case InvalidOtpException e:
        return InvalidCodeFailure(e.message);
      case ExpiredOtpException e:
        return ExpiredCodeFailure(e.message);
      case RateLimitedException e:
        return RateLimitedFailure(e.message);
      case SamePasswordException e:
        return SamePasswordFailure(e.message);
      case SignUpDisabledException e:
        return SignUpDisabledFailure(e.message);
      case ServerException e:
        return ServerFailure(e.message);
      case NetworkException _:
        return const NetworkFailure(
          'No connection. Please check your network and try again.',
        );
    }

    // Log the type only — auth payloads must never reach the console.
    debugPrint('Unmapped auth error: ${error.runtimeType}');
    return const UnknownFailure('An unexpected error occurred.');
  }

  /// Runs [action] and folds anything it throws through [_toFailure].
  Future<Either<Failure, T>> _attempt<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } catch (e) {
      return Left(_toFailure(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> checkAuthStatus() =>
      _attempt(() async => (await supabaseDataSource.checkAuthStatus()).toEntity());

  @override
  Future<Either<Failure, UserEntity>> emailPasswordSignIn(
    LoginParams params,
  ) =>
      _attempt(() async {
        final user = await supabaseDataSource.emailPasswordSignIn(
          params.email,
          params.password,
        );
        return user.toEntity();
      });

  @override
  Future<Either<Failure, UserEntity>> googleSignIn() =>
      _attempt(() async => (await supabaseDataSource.googleSignIn()).toEntity());

  @override
  Future<Either<Failure, Unit>> logOut() => _attempt(() async {
    await supabaseDataSource.logOut();
    return unit;
  });

  @override
  Future<Either<Failure, SignUpResultEntity>> signUp(SignUpParams params) =>
      _attempt(() async {
        final result = await supabaseDataSource.signUp(
          params.email,
          params.password,
        );
        return result.toEntity();
      });

  @override
  Future<Either<Failure, UserEntity>> verifySignUpCode(
    VerifySignUpCodeParams params,
  ) =>
      _attempt(() async {
        final user = await supabaseDataSource.verifySignUpCode(
          params.email,
          params.code,
        );
        return user.toEntity();
      });

  @override
  Future<Either<Failure, Unit>> resendSignUpEmail(String email) =>
      _attempt(() async {
        await supabaseDataSource.resendSignUpEmail(email);
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> requestPasswordReset(String email) =>
      _attempt(() async {
        await supabaseDataSource.requestPasswordReset(email);
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> verifyPasswordResetCode(
    VerifyPasswordResetCodeParams params,
  ) =>
      _attempt(() async {
        await supabaseDataSource.verifyPasswordResetCode(
          params.email,
          params.code,
        );
        return unit;
      });

  @override
  Future<Either<Failure, UserEntity>> updatePassword(String newPassword) =>
      _attempt(() async {
        final user = await supabaseDataSource.updatePassword(newPassword);
        return user.toEntity();
      });

  @override
  Stream<void> get onExternalSignIn => supabaseDataSource.onSignedIn;
}
