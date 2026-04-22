import 'package:car_social_media_app/features/authentication/data/datasources/supabase_auth_data_source.dart';
import 'package:car_social_media_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login/email_password_signin.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseAuthDataSource supabaseDataSource;

  AuthRepositoryImpl(this.supabaseDataSource);

  @override
  Future<Either<Failure, UserEntity>> emailPasswordSignIn(LoginParams params) async {
    try {
      final user = await supabaseDataSource.emailPasswordSignIn(params.email, params.password);
      return Right(user.toEntity());
    } 
    on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } 
    catch (e) {
      return const Left(ServerFailure("An unexpected error occurred."));
    }
  }
  
  @override
  Future<Either<Failure, UserEntity>> googleSignIn() async {
    try {
      final userModel = await supabaseDataSource.googleSignIn();
      return Right(userModel.toEntity());
    } 
    on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } 
    catch (e) {
      return const Left(ServerFailure('Eroare neprevăzută'));
    }
  }
}
