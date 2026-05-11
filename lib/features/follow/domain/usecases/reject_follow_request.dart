import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/follow_repository.dart';

class RejectFollowRequestParams {
  final String username;
  const RejectFollowRequestParams({required this.username});
}

@lazySingleton
class RejectFollowRequestUseCase
    implements UseCase<Unit, RejectFollowRequestParams> {
  final FollowRepository repository;

  RejectFollowRequestUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(RejectFollowRequestParams params) {
    return repository.rejectRequest(params.username);
  }
}
