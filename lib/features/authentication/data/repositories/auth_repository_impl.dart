import 'package:car_social_media_app/features/authentication/data/datasources/supabase_auth_data_source.dart';
import 'package:car_social_media_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/error/base_failures.dart';
import '../exceptions/auth_exceptions.dart';
import '../../domain/failures/auth_failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login/email_password_signin.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseAuthDataSource supabaseDataSource;

  AuthRepositoryImpl(this.supabaseDataSource);

  @override
  Future<Either<Failure, UserEntity>> checkAuthStatus() async {
    try {
      final userModel = await supabaseDataSource.checkAuthStatus();
      return Right(userModel.toEntity());
    } on NoActiveSessionException catch (e) {
      return Left(UnauthenticatedFailure(e.message));
    }
    on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
    catch (e) {
      debugPrint("Unexpected error in checkAuthStatus: $e");
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> emailPasswordSignIn(
    LoginParams params,
  ) async {
    try {
      final user = await supabaseDataSource.emailPasswordSignIn(
        params.email,
        params.password,
      );
      return Right(user.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> googleSignIn() async {
    try {
      final user = await supabaseDataSource.googleSignIn();
      return Right(user.toEntity());
    } on NoActiveSessionException catch (e) {
      return Left(UnauthenticatedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> logOut() async {
    try {
      await supabaseDataSource.logOut();
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('Unexpected error in logOut: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }
}
