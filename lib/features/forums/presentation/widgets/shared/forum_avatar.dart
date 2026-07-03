import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Small circular avatar with an initial-letter fallback. [username] null
/// (deleted author) renders a neutral placeholder.
class ForumAvatar extends StatelessWidget {
  final String? username;
  final String? avatarUrl;
  final double size;

  const ForumAvatar({
    super.key,
    this.username,
    this.avatarUrl,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        shape: BoxShape.circle,
        image: url == null
            ? null
            : DecorationImage(
                image: CachedNetworkImageProvider(url),
                fit: BoxFit.cover,
              ),
      ),
      alignment: Alignment.center,
      child: url != null
          ? null
          : Text(
              username == null || username!.isEmpty
                  ? '?'
                  : username![0].toUpperCase(),
              style: TextStyle(
                color: AppColors.accentHot,
                fontSize: size * 0.45,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }
}
