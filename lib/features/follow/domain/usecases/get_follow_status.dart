import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/follow_status.dart';
import '../repositories/follow_repository.dart';

class GetFollowStatusParams {
  final String username;
  const GetFollowStatusParams({required this.username});
}

@lazySingleton
class GetFollowStatusUseCase
    implements UseCase<FollowStatusEntity, GetFollowStatusParams> {
  final FollowRepository repository;

  GetFollowStatusUseCase(this.repository);

  @override
  Future<Either<Failure, FollowStatusEntity>> call(
    GetFollowStatusParams params,
  ) {
    return repository.getFollowStatus(params.username);
  }
}
