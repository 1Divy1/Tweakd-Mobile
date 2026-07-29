import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// The 44px square icon button used in messaging top bars (back, compose).
class MessagePillButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const MessagePillButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: Icon(icon, color: AppColors.ink, size: 22),
      ),
    );
  }
}
