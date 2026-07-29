import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// Notifications header: back button, centred "NOTIFICATIONS" title and a
/// "mark all read" action that only lights up while something is unread.
class NotificationsTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final bool canMarkAllRead;
  final VoidCallback onMarkAllRead;

  const NotificationsTopBar({
    super.key,
    required this.onBack,
    required this.canMarkAllRead,
    required this.onMarkAllRead,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          _PillButton(icon: Icons.chevron_left_rounded, onTap: onBack),
          Expanded(
            child: Text(
              l10n.notificationsTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
              ),
            ),
          ),
          _PillButton(
            icon: Icons.done_all_rounded,
            tooltip: l10n.notificationsMarkAllRead,
            onTap: canMarkAllRead ? onMarkAllRead : null,
          ),
        ],
      ),
    );
  }
}

/// A 44px square icon button. A null [onTap] renders the button disabled
/// (dimmed icon, no gesture) — used for "mark all read" when nothing's unread.
class _PillButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;

  const _PillButton({required this.icon, this.onTap, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final button = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.ink : AppColors.muteSoft,
          size: 22,
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}
