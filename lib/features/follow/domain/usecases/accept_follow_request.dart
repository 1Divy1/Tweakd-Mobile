import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/follow_repository.dart';

class AcceptFollowRequestParams {
  final String username;
  const AcceptFollowRequestParams({required this.username});
}

@lazySingleton
class AcceptFollowRequestUseCase
    implements UseCase<Unit, AcceptFollowRequestParams> {
  final FollowRepository repository;

  AcceptFollowRequestUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(AcceptFollowRequestParams params) {
    return repository.acceptRequest(params.username);
  }
}
