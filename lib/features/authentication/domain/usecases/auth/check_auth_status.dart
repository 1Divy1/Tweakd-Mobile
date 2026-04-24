import 'package:car_social_media_app/core/error/base_failures.dart';
import 'package:car_social_media_app/core/usecases/usecase.dart';
import 'package:car_social_media_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../entities/user.dart';

@lazySingleton
class CheckAuthStatusUseCase implements UseCase<UserEntity, NoParams> {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) async {
    return await repository.checkAuthStatus();
  }
}