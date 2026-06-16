import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// The "Tweakd." brand mark (black tile + orange bolt and wordmark) shown at
/// the top of both the login and sign up pages.
class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: const TextSpan(
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
          children: [
            TextSpan(
              text: 'Tweakd',
              style: TextStyle(color: AppColors.ink),
            ),
            TextSpan(
              text: '.',
              style: TextStyle(color: AppColors.accent),
            ),
          ],
        ),
      ),
    );
  }
}
