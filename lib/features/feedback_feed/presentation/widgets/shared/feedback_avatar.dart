import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
    final url = avatarUrl;
    // Cap decode resolution to the on-screen size — otherwise a full-resolution
    // source image is decoded for every small circle while scrolling.
    final cachePx = (size * MediaQuery.devicePixelRatioOf(context)).round();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.line2,
        shape: BoxShape.circle,
        image: url == null || url.isEmpty
            ? null
            : DecorationImage(
                image: ResizeImage(
                  CachedNetworkImageProvider(url),
                  width: cachePx,
                  height: cachePx,
                ),
                fit: BoxFit.cover,
              ),
      ),
      alignment: Alignment.center,
      child: url != null && url.isNotEmpty
          ? null
          : Text(
              username.isEmpty ? '?' : username[0].toUpperCase(),
              style: TextStyle(
                color: AppColors.ink2,
                fontSize: size * 0.4,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }
}
