import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// The 44px rounded-square icon button used app-wide for back/menu/bell
/// affordances in top bars: white fill, 18-unit rounding, no border.
class AppPillButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  const AppPillButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 44,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, color: AppColors.ink, size: iconSize),
      ),
    );
  }
}
