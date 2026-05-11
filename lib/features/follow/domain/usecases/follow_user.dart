import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/follow_status.dart';
import '../repositories/follow_repository.dart';

class FollowUserParams {
  final String username;
  const FollowUserParams({required this.username});
}

@lazySingleton
class FollowUserUseCase implements UseCase<FollowStatusEntity, FollowUserParams> {
  final FollowRepository repository;

  FollowUserUseCase(this.repository);

  @override
  Future<Either<Failure, FollowStatusEntity>> call(FollowUserParams params) {
    return repository.follow(params.username);
  }
}
