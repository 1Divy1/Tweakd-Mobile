import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/app_avatar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// Asks the user to confirm an action that removes a follow connection —
/// unfollowing someone, or removing one of their own followers.
///
/// Losing a connection thins the feed on both sides, so it's deliberately one
/// step further away than following. Cancel is the easy, neutral choice; the
/// destructive action is tinted. Resolves to `true` only when confirmed.
Future<bool> showFollowConfirmSheet(
  BuildContext context, {
  required String username,
  required String? avatarUrl,
  required String title,
  required String body,
  required String confirmLabel,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.surface,
    // Lets the sheet grow past half the screen at large text sizes; the scroll
    // view keeps it usable on a short landscape screen.
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            AppAvatar(size: 64, url: avatarUrl, name: username),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mute,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            _SheetButton(
              label: confirmLabel,
              color: AppColors.accentHot,
              background: AppColors.bg,
              onTap: () => Navigator.of(sheetContext).pop(true),
            ),
            const SizedBox(height: 8),
            _SheetButton(
              label: l10n.commonCancel,
              color: AppColors.ink,
              onTap: () => Navigator.of(sheetContext).pop(false),
            ),
          ],
        ),
      ),
    ),
  );
  return confirmed ?? false;
}

class _SheetButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color? background;
  final VoidCallback onTap;

  const _SheetButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: background,
          foregroundColor: color,
          minimumSize: const Size.fromHeight(50),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
