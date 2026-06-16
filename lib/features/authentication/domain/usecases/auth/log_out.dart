import 'package:car_social_media_app/core/error/base_failures.dart';
import 'package:car_social_media_app/core/usecases/usecase.dart';
import 'package:car_social_media_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class LogOut implements UseCase<Unit, NoParams> {
  final AuthRepository repository;

  LogOut(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    return await repository.logOut();
  }
}
