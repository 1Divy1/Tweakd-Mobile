import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class PostCard extends StatelessWidget {
  final PostCard post;
  final VoidCallback onTap;

  const PostCard({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line),
        ),
        clipBehavior: Clip.hardEdge,
      ),
    );
  }
}
