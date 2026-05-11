import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class ProfileIdentity extends StatelessWidget {
  final String name;
  final String username;

  const ProfileIdentity({
    super.key,
    required this.name,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          name.isEmpty ? '—' : name,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '@$username',
          style: const TextStyle(
            color: AppColors.mute,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
