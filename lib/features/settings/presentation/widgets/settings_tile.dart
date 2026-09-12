import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A full-width tappable settings row: leading icon, label, trailing chevron.
/// [trailingLabel], if set, renders small muted text just before the chevron
/// (e.g. the current value of a setting).
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailingLabel;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.label,
    this.trailingLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.ink, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            if (trailingLabel != null) ...[
              Text(
                trailingLabel!,
                style: TextStyle(
                  color: AppColors.mute,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Icon(Icons.chevron_right, color: AppColors.muteSoft, size: 20),
          ],
        ),
      ),
    );
  }
}
