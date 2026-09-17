import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// "Block @username?" — shown before blocking from a public profile.
/// Resolves to `true` only when the user confirmed.
Future<bool> showBlockConfirmDialog(
  BuildContext context, {
  required String username,
}) {
  final l10n = AppLocalizations.of(context)!;
  return _showConfirmDialog(
    context,
    title: l10n.profileBlockTitle(username),
    body: l10n.profileBlockBody,
    confirmLabel: l10n.profileBlockConfirm,
  );
}

/// "Unblock @username?" — guards against accidental unblocks from the
/// blocked accounts list. Resolves to `true` only when the user confirmed.
Future<bool> showUnblockConfirmDialog(
  BuildContext context, {
  required String username,
}) {
  final l10n = AppLocalizations.of(context)!;
  return _showConfirmDialog(
    context,
    title: l10n.blockedAccountsUnblockTitle(username),
    body: l10n.blockedAccountsUnblockBody,
    confirmLabel: l10n.blockedAccountsUnblock,
  );
}

Future<bool> _showConfirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.surface,
      // Long copy at large text scales scrolls instead of overflowing.
      scrollable: true,
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(
            l10n.commonCancel,
            style: TextStyle(color: AppColors.ink2),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(
            confirmLabel,
            style: TextStyle(
              color: AppColors.accentHot,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
  return confirmed == true;
}
