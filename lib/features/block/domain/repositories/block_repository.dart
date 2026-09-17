import 'package:dartz/dartz.dart';

import '../../../../core/error/base_failures.dart';
import '../entities/blocked_account.dart';

abstract class BlockRepository {
  /// Blocks [username]. The backend also removes any follow between the two
  /// accounts, and never notifies the blocked user.
  Future<Either<Failure, Unit>> block(String username);

  Future<Either<Failure, Unit>> unblock(String username);

  /// The accounts the current user has blocked, most recent first.
  Future<Either<Failure, List<BlockedAccountEntity>>> getBlockedAccounts();
}
