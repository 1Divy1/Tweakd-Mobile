import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/follow_user.dart';
import '../repositories/follow_repository.dart';

class GetFollowersParams {
  final String username;
  const GetFollowersParams({required this.username});
}

@lazySingleton
class GetFollowersUseCase
    implements UseCase<List<FollowUserEntity>, GetFollowersParams> {
  final FollowRepository repository;

  GetFollowersUseCase(this.repository);

  @override
  Future<Either<Failure, List<FollowUserEntity>>> call(
    GetFollowersParams params,
  ) {
    return repository.getFollowers(params.username);
  }
}
