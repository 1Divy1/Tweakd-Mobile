import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A horizontal rule with centered uppercase text, e.g. "OR CONTINUE WITH".
class AuthDivider extends StatelessWidget {
  final String label;

  const AuthDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.line, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              color: AppColors.mute,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.line, thickness: 1)),
      ],
    );
  }
}
