import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/follow_repository.dart';

class UnfollowUserParams {
  final String username;
  const UnfollowUserParams({required this.username});
}

@lazySingleton
class UnfollowUserUseCase implements UseCase<Unit, UnfollowUserParams> {
  final FollowRepository repository;

  UnfollowUserUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(UnfollowUserParams params) {
    return repository.unfollow(params.username);
  }
}
