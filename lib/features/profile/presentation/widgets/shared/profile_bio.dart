import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class ProfileBio extends StatelessWidget {
  final String bio;

  const ProfileBio({super.key, required this.bio});

  @override
  Widget build(BuildContext context) {
    return Text(
      bio,
      style: TextStyle(color: AppColors.ink2, fontSize: 14, height: 1.45),
    );
  }
}
