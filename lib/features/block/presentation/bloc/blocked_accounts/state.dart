import 'package:equatable/equatable.dart';

import '../../../domain/entities/blocked_account.dart';
import '../../utils/block_error_mapper.dart';

sealed class BlockedAccountsState extends Equatable {
  const BlockedAccountsState();

  @override
  List<Object?> get props => [];
}

class BlockedAccountsInitial extends BlockedAccountsState {
  const BlockedAccountsInitial();
}

class BlockedAccountsLoading extends BlockedAccountsState {
  const BlockedAccountsLoading();
}

class BlockedAccountsError extends BlockedAccountsState {
  final BlockErrorCode code;
  const BlockedAccountsError(this.code);

  @override
  List<Object?> get props => [code];
}

class BlockedAccountsLoaded extends BlockedAccountsState {
  final List<BlockedAccountEntity> accounts;

  /// Usernames with an unblock request in flight; their button shows a spinner.
  final Set<String> unblocking;

  /// The latest one-shot outcome, for the page to show as a snackbar.
  final BlockedAccountsNotice? notice;

  /// Bumped with every new [notice], so two identical outcomes in a row still
  /// count as distinct states.
  final int noticeId;

  const BlockedAccountsLoaded({
    required this.accounts,
    this.unblocking = const {},
    this.notice,
    this.noticeId = 0,
  });

  BlockedAccountsLoaded copyWith({
    List<BlockedAccountEntity>? accounts,
    Set<String>? unblocking,
    BlockedAccountsNotice? notice,
    int? noticeId,
  }) {
    return BlockedAccountsLoaded(
      accounts: accounts ?? this.accounts,
      unblocking: unblocking ?? this.unblocking,
      notice: notice ?? this.notice,
      noticeId: noticeId ?? this.noticeId,
    );
  }

  @override
  List<Object?> get props => [accounts, unblocking, notice, noticeId];
}

sealed class BlockedAccountsNotice extends Equatable {
  final String username;
  const BlockedAccountsNotice(this.username);

  @override
  List<Object?> get props => [username];
}

class UnblockSucceeded extends BlockedAccountsNotice {
  const UnblockSucceeded(super.username);
}

class UnblockFailed extends BlockedAccountsNotice {
  final BlockErrorCode code;
  const UnblockFailed(super.username, this.code);

  @override
  List<Object?> get props => [username, code];
}
