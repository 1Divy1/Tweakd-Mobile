import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/usecases/usecase.dart';
import '../../../domain/usecases/get_blocked_accounts.dart';
import '../../../domain/usecases/unblock_user.dart';
import '../../utils/block_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Backs Settings → Blocked accounts: loads the list and unblocks accounts
/// from it. A successfully unblocked account leaves the list at once.
@injectable
class BlockedAccountsBloc
    extends Bloc<BlockedAccountsEvent, BlockedAccountsState> {
  final GetBlockedAccountsUseCase getBlockedAccounts;
  final UnblockUserUseCase unblockUser;

  BlockedAccountsBloc({
    required this.getBlockedAccounts,
    required this.unblockUser,
  }) : super(const BlockedAccountsInitial()) {
    on<LoadBlockedAccounts>(_onLoad);
    on<UnblockAccount>(_onUnblock);
  }

  Future<void> _onLoad(
    LoadBlockedAccounts event,
    Emitter<BlockedAccountsState> emit,
  ) async {
    emit(const BlockedAccountsLoading());
    final result = await getBlockedAccounts(NoParams());
    result.fold(
      (failure) => emit(BlockedAccountsError(BlockErrorMapper.getCode(failure))),
      (accounts) => emit(BlockedAccountsLoaded(accounts: accounts)),
    );
  }

  Future<void> _onUnblock(
    UnblockAccount event,
    Emitter<BlockedAccountsState> emit,
  ) async {
    final current = state;
    if (current is! BlockedAccountsLoaded ||
        current.unblocking.contains(event.username)) {
      return;
    }
    emit(current.copyWith(unblocking: {...current.unblocking, event.username}));

    final result = await unblockUser(UnblockUserParams(username: event.username));

    // Other unblocks may have finished meanwhile — build on the latest state.
    final latest = state;
    if (latest is! BlockedAccountsLoaded) return;
    final unblocking = {...latest.unblocking}..remove(event.username);
    final remaining =
        latest.accounts.where((a) => a.username != event.username).toList();

    result.fold(
      (failure) {
        final code = BlockErrorMapper.getCode(failure);
        if (code == BlockErrorCode.notFound) {
          // The account no longer exists, so there is nothing left to unblock.
          emit(latest.copyWith(
            accounts: remaining,
            unblocking: unblocking,
            notice: UnblockSucceeded(event.username),
            noticeId: latest.noticeId + 1,
          ));
          return;
        }
        emit(latest.copyWith(
          unblocking: unblocking,
          notice: UnblockFailed(event.username, code),
          noticeId: latest.noticeId + 1,
        ));
      },
      (_) => emit(latest.copyWith(
        accounts: remaining,
        unblocking: unblocking,
        notice: UnblockSucceeded(event.username),
        noticeId: latest.noticeId + 1,
      )),
    );
  }
}
