import 'package:flutter/material.dart';

import '../../../../../core/shared/widgets/app_avatar.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/blocked_account.dart';

/// One row of the blocked accounts list: avatar, username (and name), and an
/// Unblock button that turns into a spinner while the request is in flight.
class BlockedAccountTile extends StatelessWidget {
  final BlockedAccountEntity account;
  final bool isUnblocking;
  final VoidCallback onUnblock;

  const BlockedAccountTile({
    super.key,
    required this.account,
    required this.isUnblocking,
    required this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    final name = account.name?.trim();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          AppAvatar(
            size: 44,
            url: account.avatarUrl,
            name: account.username,
            backgroundColor: AppColors.line2,
            initialColor: AppColors.muteSoft,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  account.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (name != null && name.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.mute,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Flexible so a long translated label at a large text scale
          // ellipsizes instead of pushing the row past the screen edge.
          Flexible(
            child: _UnblockButton(
              isUnblocking: isUnblocking,
              onTap: onUnblock,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnblockButton extends StatelessWidget {
  final bool isUnblocking;
  final VoidCallback onTap;

  const _UnblockButton({required this.isUnblocking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isUnblocking ? null : onTap,
      style: OutlinedButton.styleFrom(
        // Tinted rather than white: the card underneath is already white.
        backgroundColor: AppColors.bg,
        disabledBackgroundColor: AppColors.bg,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: isUnblocking
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accent,
              ),
            )
          : Text(
              AppLocalizations.of(context)!.blockedAccountsUnblock,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}
