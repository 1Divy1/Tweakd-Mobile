import 'package:flutter/material.dart';

import '../../../../../core/shared/widgets/app_avatar.dart';
import '../../../../../core/theme/app_colors.dart';

/// Circular author avatar with an initial-letter fallback, as on the board
/// cards.
class FeedbackAvatar extends StatelessWidget {
  final String username;
  final String? avatarUrl;
  final double size;

  const FeedbackAvatar({
    super.key,
    required this.username,
    this.avatarUrl,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return AppAvatar(
      size: size,
      url: avatarUrl,
      name: username,
      backgroundColor: AppColors.line2,
      initialColor: AppColors.ink2,
    );
  }
}
