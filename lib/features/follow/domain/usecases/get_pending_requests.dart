import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/follow_request.dart';
import '../repositories/follow_repository.dart';

@lazySingleton
class GetPendingRequestsUseCase
    implements UseCase<List<FollowRequestEntity>, NoParams> {
  final FollowRepository repository;

  GetPendingRequestsUseCase(this.repository);

  @override
  Future<Either<Failure, List<FollowRequestEntity>>> call(NoParams params) {
    return repository.getPendingRequests();
  }
}
