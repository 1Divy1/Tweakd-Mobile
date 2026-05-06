import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class FollowButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FollowButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add, color: Colors.white, size: 20),
        label: const Text(
          'FOLLOW',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
