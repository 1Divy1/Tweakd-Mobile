import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/core/error/base_failures.dart';
import 'package:tweakd/features/block/domain/entities/blocked_account.dart';
import 'package:tweakd/features/block/domain/failures/block_failures.dart';
import 'package:tweakd/features/block/domain/repositories/block_repository.dart';
import 'package:tweakd/features/block/domain/usecases/block_user.dart';
import 'package:tweakd/features/block/domain/usecases/get_blocked_accounts.dart';
import 'package:tweakd/features/block/domain/usecases/unblock_user.dart';
import 'package:tweakd/features/block/presentation/bloc/block_user/cubit.dart';
import 'package:tweakd/features/block/presentation/bloc/block_user/state.dart';
import 'package:tweakd/features/block/presentation/bloc/blocked_accounts/bloc.dart';
import 'package:tweakd/features/block/presentation/bloc/blocked_accounts/event.dart';
import 'package:tweakd/features/block/presentation/bloc/blocked_accounts/state.dart';
import 'package:tweakd/features/block/presentation/utils/block_error_mapper.dart';

class _FakeBlockRepository implements BlockRepository {
  List<BlockedAccountEntity> accounts;
  Failure? unblockFailure;
  Failure? blockFailure;
  final calls = <String>[];

  _FakeBlockRepository(this.accounts);

  @override
  Future<Either<Failure, Unit>> block(String username) async {
    calls.add('block:$username');
    return blockFailure != null ? Left(blockFailure!) : const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> unblock(String username) async {
    calls.add('unblock:$username');
    return unblockFailure != null ? Left(unblockFailure!) : const Right(unit);
  }

  @override
  Future<Either<Failure, List<BlockedAccountEntity>>> getBlockedAccounts() async {
    calls.add('list');
    return Right(accounts);
  }
}

const _alice = BlockedAccountEntity(id: 'a', username: 'alice');
const _bob = BlockedAccountEntity(id: 'b', username: 'bob', name: 'Bob');

Future<void> _settle() => Future<void>.delayed(Duration.zero);

/// Settings → Blocked accounts: load, then unblock with the row leaving the
/// list on success, staying (with a failure notice) otherwise.
void main() {
  late _FakeBlockRepository repo;
  late BlockedAccountsBloc bloc;

  setUp(() {
    repo = _FakeBlockRepository([_alice, _bob]);
    bloc = BlockedAccountsBloc(
      getBlockedAccounts: GetBlockedAccountsUseCase(repo),
      unblockUser: UnblockUserUseCase(repo),
    );
  });

  tearDown(() => bloc.close());

  Future<void> load() async {
    bloc.add(const LoadBlockedAccounts());
    await _settle();
    await _settle();
  }

  test('loads the blocked accounts', () async {
    await load();
    final state = bloc.state as BlockedAccountsLoaded;
    expect(state.accounts, [_alice, _bob]);
    expect(state.unblocking, isEmpty);
    expect(state.notice, isNull);
  });

  test('a successful unblock removes the account from the list', () async {
    await load();

    bloc.add(const UnblockAccount('alice'));
    await _settle();
    await _settle();

    final state = bloc.state as BlockedAccountsLoaded;
    expect(repo.calls, contains('unblock:alice'));
    expect(state.accounts, [_bob]);
    expect(state.unblocking, isEmpty);
    expect(state.notice, const UnblockSucceeded('alice'));
    expect(state.noticeId, 1);
  });

  test('a failed unblock keeps the account and reports the failure', () async {
    await load();
    repo.unblockFailure = const NetworkFailure('offline');

    bloc.add(const UnblockAccount('bob'));
    await _settle();
    await _settle();

    final state = bloc.state as BlockedAccountsLoaded;
    expect(state.accounts, [_alice, _bob]);
    expect(state.unblocking, isEmpty);
    expect(state.notice, const UnblockFailed('bob', BlockErrorCode.network));
  });

  test('an account that no longer exists simply leaves the list', () async {
    await load();
    repo.unblockFailure = const BlockTargetNotFoundFailure();

    bloc.add(const UnblockAccount('alice'));
    await _settle();
    await _settle();

    final state = bloc.state as BlockedAccountsLoaded;
    expect(state.accounts, [_bob]);
    expect(state.notice, const UnblockSucceeded('alice'));
  });

  test('the same failure twice still produces a new notice', () async {
    await load();
    repo.unblockFailure = const ServerFailure('boom');

    bloc.add(const UnblockAccount('bob'));
    await _settle();
    await _settle();
    bloc.add(const UnblockAccount('bob'));
    await _settle();
    await _settle();

    expect((bloc.state as BlockedAccountsLoaded).noticeId, 2);
  });

  group('BlockUserCubit', () {
    test('emits success with the username', () async {
      final cubit = BlockUserCubit(blockUser: BlockUserUseCase(repo));
      await cubit.block('carol');
      expect(cubit.state, const BlockUserSuccess('carol'));
      expect(repo.calls, contains('block:carol'));
      await cubit.close();
    });

    test('maps a self-block failure', () async {
      repo.blockFailure = const CannotBlockSelfFailure();
      final cubit = BlockUserCubit(blockUser: BlockUserUseCase(repo));
      await cubit.block('me');
      expect(cubit.state, const BlockUserFailure(BlockErrorCode.selfBlock));
      await cubit.close();
    });
  });
}
