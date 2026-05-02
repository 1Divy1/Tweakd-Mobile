import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/error/base_failures.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasource/profile_api_data_source.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileApiDataSource profileApiDataSource;

  ProfileRepositoryImpl(this.profileApiDataSource);

  @override
  Future<Either<Failure, ProfileEntity>> getCurrentUserProfile() async {
    try {
      final profile = await profileApiDataSource.getCurrentUserProfile();
      return Right(profile.toEntity());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('Unexpected error in getCurrentUserProfile: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }
}
