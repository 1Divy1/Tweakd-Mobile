import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Small uppercase section label ("YOUR SHORTCUTS", "MODELS", …).
class ForumSectionLabel extends StatelessWidget {
  final String label;

  const ForumSectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: AppColors.mute,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
      ),
    );
  }
}
