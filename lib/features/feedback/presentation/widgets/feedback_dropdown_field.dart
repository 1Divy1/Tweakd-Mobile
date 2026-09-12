import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// The closed state of a "dropdown": a tappable surface showing the current
/// selection (an optional accent icon badge, a title and optional subtitle) with
/// a trailing chevron. Tapping opens the corresponding picker sheet.
class FeedbackDropdownField extends StatelessWidget {
  final IconData? leadingIcon;
  final String title;
  final String? subtitle;

  /// When true the [title] is rendered as muted placeholder text (nothing picked
  /// yet), otherwise as the solid selected value.
  final bool isPlaceholder;
  final bool enabled;
  final VoidCallback onTap;

  const FeedbackDropdownField({
    super.key,
    this.leadingIcon,
    required this.title,
    this.subtitle,
    this.isPlaceholder = false,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(leadingIcon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isPlaceholder ? AppColors.mute : AppColors.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
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
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.mute,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
