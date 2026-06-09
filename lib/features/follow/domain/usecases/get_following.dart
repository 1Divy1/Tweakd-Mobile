import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/follow_list_user.dart';
import '../repositories/follow_repository.dart';

class GetFollowingParams {
  final String username;
  const GetFollowingParams({required this.username});
}

@lazySingleton
class GetFollowingUseCase implements UseCase<List<FollowListUserEntity>, GetFollowingParams> {
  final FollowRepository repository;

  GetFollowingUseCase(this.repository);

  @override
  Future<Either<Failure, List<FollowListUserEntity>>> call(
    GetFollowingParams params,
  ) {
    return repository.getFollowing(params.username);
  }
}
