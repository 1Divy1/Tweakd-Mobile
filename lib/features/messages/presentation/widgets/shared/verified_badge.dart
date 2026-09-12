import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// The small orange check badge shown next to verified usernames.
class VerifiedBadge extends StatelessWidget {
  final double size;

  const VerifiedBadge({super.key, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check_rounded,
        color: Colors.white,
        size: size * 0.68,
      ),
    );
  }
}
