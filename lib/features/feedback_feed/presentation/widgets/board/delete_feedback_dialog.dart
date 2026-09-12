import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

/// Confirms a hard delete. Returns true when the author goes through with it.
///
/// Worth confirming because the delete is irreversible and takes the message's
/// votes with it — and because the window is narrow: once staff pick the
/// message up, the option disappears entirely.
Future<bool> showDeleteFeedbackDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Text(
        l10n.feedbackFeedDeleteTitle,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
        ),
      ),
      content: Text(
        l10n.feedbackFeedDeleteBody,
        style: TextStyle(
          fontSize: 14,
          height: 1.4,
          color: AppColors.ink2,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          style: TextButton.styleFrom(foregroundColor: AppColors.mute),
          child: Text(l10n.feedbackFeedCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accentHot,
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
          child: Text(l10n.feedbackFeedDelete),
        ),
      ],
    ),
  );

  return confirmed ?? false;
}
