import 'package:equatable/equatable.dart';

sealed class BlockedAccountsEvent extends Equatable {
  const BlockedAccountsEvent();

  @override
  List<Object?> get props => [];
}

/// Loads (or reloads, for retry) the accounts the user has blocked.
class LoadBlockedAccounts extends BlockedAccountsEvent {
  const LoadBlockedAccounts();
}

/// Unblocks [username]. Dispatched only after the user confirmed the dialog.
class UnblockAccount extends BlockedAccountsEvent {
  final String username;
  const UnblockAccount(this.username);

  @override
  List<Object?> get props => [username];
}
