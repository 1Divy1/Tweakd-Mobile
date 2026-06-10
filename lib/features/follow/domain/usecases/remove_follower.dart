import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/follow_repository.dart';

class RemoveFollowerParams {
  final String username;
  const RemoveFollowerParams({required this.username});
}

@lazySingleton
class RemoveFollowerUseCase implements UseCase<Unit, RemoveFollowerParams> {
  final FollowRepository repository;

  RemoveFollowerUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(RemoveFollowerParams params) {
    return repository.removeFollower(params.username);
  }
}
