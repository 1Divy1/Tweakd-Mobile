import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/block_repository.dart';

class BlockUserParams {
  final String username;
  const BlockUserParams({required this.username});
}

@lazySingleton
class BlockUserUseCase implements UseCase<Unit, BlockUserParams> {
  final BlockRepository repository;

  BlockUserUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(BlockUserParams params) {
    return repository.block(params.username);
  }
}
