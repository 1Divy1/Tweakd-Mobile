import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/blocked_account.dart';
import '../repositories/block_repository.dart';

@lazySingleton
class GetBlockedAccountsUseCase
    implements UseCase<List<BlockedAccountEntity>, NoParams> {
  final BlockRepository repository;

  GetBlockedAccountsUseCase(this.repository);

  @override
  Future<Either<Failure, List<BlockedAccountEntity>>> call(NoParams params) {
    return repository.getBlockedAccounts();
  }
}
