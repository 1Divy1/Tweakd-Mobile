import 'package:car_social_media_app/core/usecases/usecase.dart';
import 'package:car_social_media_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/base_failures.dart';

@lazySingleton
class GoogleSignIn implements UseCase<void, NoParams> {
  final AuthRepository repository;

  GoogleSignIn(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.googleSignIn();
  }
}