import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

/// Actions offered by the public profile "⋯" menu: blocking and reporting the
/// account. More options (mute, notifications, …) slot in here later.
enum ProfileMenuAction { block, report }

/// Opens the public profile options bottom sheet. Resolves to the tapped
/// [ProfileMenuAction], or `null` if dismissed without a choice.
Future<ProfileMenuAction?> showProfileOptionsSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return showModalBottomSheet<ProfileMenuAction>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          _OptionRow(
            icon: Icons.block_rounded,
            label: l10n.profileBlockAccount,
            destructive: true,
            onTap: () =>
                Navigator.of(sheetContext).pop(ProfileMenuAction.block),
          ),
          _OptionRow(
            icon: Icons.flag_outlined,
            label: l10n.profileReportAccount,
            destructive: true,
            onTap: () =>
                Navigator.of(sheetContext).pop(ProfileMenuAction.report),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

class _OptionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool destructive;
  final VoidCallback onTap;

  const _OptionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.accentHot : AppColors.ink;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
