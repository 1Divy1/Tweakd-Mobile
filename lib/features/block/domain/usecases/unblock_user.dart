import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/block_repository.dart';

class UnblockUserParams {
  final String username;
  const UnblockUserParams({required this.username});
}

@lazySingleton
class UnblockUserUseCase implements UseCase<Unit, UnblockUserParams> {
  final BlockRepository repository;

  UnblockUserUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(UnblockUserParams params) {
    return repository.unblock(params.username);
  }
}
