import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// The 44px rounded-square icon button used app-wide for back/menu/bell
/// affordances in top bars: white fill, 18-unit rounding, no border.
class AppPillButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  /// Optional clockwise rotation for the icon, in degrees (e.g. -45 to point
  /// an arrow/send-style icon toward the top-right corner).
  final double iconRotation;

  /// Optional visual nudge for the icon, to correct for glyphs whose ink
  /// isn't centered within their bounding box (e.g. a rotated send icon).
  final Offset iconOffset;

  const AppPillButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 44,
    this.iconSize = 22,
    this.iconRotation = 0,
    this.iconOffset = Offset.zero,
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
        child: Transform.translate(
          offset: iconOffset,
          child: Transform.rotate(
            angle: iconRotation * math.pi / 180,
            child: Icon(icon, color: AppColors.ink, size: iconSize),
          ),
        ),
      ),
    );
  }
}
