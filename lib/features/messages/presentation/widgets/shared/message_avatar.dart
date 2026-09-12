import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Circular avatar for messaging surfaces, with an initial-letter fallback
/// and an optional online dot pinned to the bottom-right edge.
class MessageAvatar extends StatelessWidget {
  final String username;
  final String? avatarUrl;
  final double size;
  final bool showOnlineDot;

  /// Color behind the online dot's border, so it visually "punches through"
  /// whatever the avatar sits on (page bg, surface tile, …).
  final Color? dotBorderColor;

  const MessageAvatar({
    super.key,
    required this.username,
    this.avatarUrl,
    this.size = 48,
    this.showOnlineDot = false,
    this.dotBorderColor,
  });

  /// Fallback tint derived from the username so mock users without photos
  /// still look distinct (like the M / J / K / L circles in the design).
  Color get _fallbackColor {
    const palette = [
      Color(0xFFD9A08C), // clay
      Color(0xFFBFC3C9), // steel
      Color(0xFFE8B4A0), // peach
      Color(0xFFC4B49A), // sand
      Color(0xFFAFB8C4), // slate
      Color(0xFFD4A5A5), // rose
    ];
    return palette[username.hashCode.abs() % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;
    // Cap decode resolution to the on-screen avatar size — otherwise every
    // full-resolution source image gets decoded for a small circle on every
    // inbox/chat row built while scrolling.
    final cachePx = (size * MediaQuery.devicePixelRatioOf(context)).round();

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _fallbackColor,
        shape: BoxShape.circle,
        image: url == null
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
      child: url != null
          ? null
          : Text(
              username.isEmpty ? '?' : username[0].toUpperCase(),
              style: TextStyle(
                // _fallbackColor is a fixed pastel, not a theme token, so the
                // glyph on it must stay fixed-dark too rather than flipping
                // to white in dark mode.
                color: AppColors.onLight.withValues(alpha: 0.55),
                fontSize: size * 0.4,
                fontWeight: FontWeight.w800,
              ),
            ),
    );

    if (!showOnlineDot) return avatar;

    final dotSize = (size * 0.28).clamp(10.0, 16.0);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
              border: Border.all(
                color: dotBorderColor ?? AppColors.bg,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
