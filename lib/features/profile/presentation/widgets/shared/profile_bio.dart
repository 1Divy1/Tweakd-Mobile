import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class ProfileBio extends StatelessWidget {
  final String bio;

  const ProfileBio({super.key, required this.bio});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        bio,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.mute,
          fontSize: 14,
          height: 1.45,
        ),
      ),
    );
  }
}
