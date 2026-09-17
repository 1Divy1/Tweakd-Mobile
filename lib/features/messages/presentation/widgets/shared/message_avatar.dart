import 'package:flutter/material.dart';

import '../../../../../core/shared/widgets/app_avatar.dart';
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
    final avatar = AppAvatar(
      size: size,
      url: avatarUrl,
      name: username,
      backgroundColor: _fallbackColor,
      // _fallbackColor is a fixed pastel, not a theme token, so the glyph on
      // it must stay fixed-dark too rather than flipping to white in dark mode.
      initialColor: AppColors.onLight.withValues(alpha: 0.55),
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
