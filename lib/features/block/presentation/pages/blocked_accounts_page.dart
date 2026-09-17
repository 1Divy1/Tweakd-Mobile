import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../profile/presentation/widgets/shared/profile_top_bar.dart';
import '../../domain/entities/blocked_account.dart';
import '../bloc/blocked_accounts/bloc.dart';
import '../bloc/blocked_accounts/event.dart';
import '../bloc/blocked_accounts/state.dart';
import '../utils/block_error_mapper.dart';
import '../widgets/block_confirm_dialog.dart';
import '../widgets/blocked_accounts/blocked_accounts_empty_view.dart';
import '../widgets/blocked_accounts/blocked_accounts_error_view.dart';
import '../widgets/blocked_accounts/blocked_accounts_list_view.dart';
import '../widgets/blocked_accounts/blocked_accounts_loading_view.dart';

/// Settings → Blocked accounts: everyone the user has blocked, each with an
/// Unblock action behind a confirmation dialog.
class BlockedAccountsPage extends StatelessWidget {
  const BlockedAccountsPage({super.key});

  Future<void> _confirmUnblock(
    BuildContext context,
    BlockedAccountEntity account,
  ) async {
    final confirmed = await showUnblockConfirmDialog(
      context,
      username: account.username,
    );
    if (confirmed && context.mounted) {
      context.read<BlockedAccountsBloc>().add(UnblockAccount(account.username));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            ProfileTopBar(title: l10n.blockedAccountsTitle),
            Expanded(
              child: BlocConsumer<BlockedAccountsBloc, BlockedAccountsState>(
                listenWhen: (previous, current) =>
                    current is BlockedAccountsLoaded &&
                    current.notice != null &&
                    (previous is! BlockedAccountsLoaded ||
                        previous.noticeId != current.noticeId),
                listener: (context, state) {
                  final notice = (state as BlockedAccountsLoaded).notice!;
                  final message = switch (notice) {
                    UnblockSucceeded(:final username) =>
                      l10n.blockedAccountsUnblocked(username),
                    UnblockFailed(:final username, :final code) =>
                      code == BlockErrorCode.network
                          ? blockErrorMessage(l10n, code)
                          : l10n.blockedAccountsUnblockError(username),
                  };
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(message)));
                },
                builder: (context, state) {
                  return switch (state) {
                    BlockedAccountsInitial() ||
                    BlockedAccountsLoading() =>
                      const BlockedAccountsLoadingView(),
                    BlockedAccountsError() => BlockedAccountsErrorView(
                        message: l10n.blockedAccountsLoadError,
                        onRetry: () => context
                            .read<BlockedAccountsBloc>()
                            .add(const LoadBlockedAccounts()),
                      ),
                    BlockedAccountsLoaded(:final accounts)
                        when accounts.isEmpty =>
                      const BlockedAccountsEmptyView(),
                    BlockedAccountsLoaded(:final accounts, :final unblocking) =>
                      BlockedAccountsListView(
                        accounts: accounts,
                        unblocking: unblocking,
                        onUnblock: (account) =>
                            _confirmUnblock(context, account),
                      ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
