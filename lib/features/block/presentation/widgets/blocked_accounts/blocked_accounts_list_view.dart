import 'package:flutter/material.dart';

import '../../../../../core/shared/layout/app_layout.dart';
import '../../../domain/entities/blocked_account.dart';
import 'blocked_account_tile.dart';

/// The loaded list of blocked accounts.
class BlockedAccountsListView extends StatelessWidget {
  final List<BlockedAccountEntity> accounts;
  final Set<String> unblocking;
  final ValueChanged<BlockedAccountEntity> onUnblock;

  const BlockedAccountsListView({
    super.key,
    required this.accounts,
    required this.unblocking,
    required this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24) +
          AppLayout.inset(context, maxWidth: AppLayout.formWidth),
      itemCount: accounts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final account = accounts[i];
        return BlockedAccountTile(
          key: ValueKey(account.id),
          account: account,
          isUnblocking: unblocking.contains(account.username),
          onUnblock: () => onUnblock(account),
        );
      },
    );
  }
}
