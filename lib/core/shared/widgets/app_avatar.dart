import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../utils/cover_resize_image.dart';

/// The one circular user avatar used across the app.
///
/// The photo is cropped to the circle with `BoxFit.cover` — never stretched —
/// and decoded at the on-screen size (see [CoverResizeImage]) so long lists
/// don't decode full-resolution uploads. Without a photo, or when it fails to
/// load, it shows the first letter of [name] (a person glyph if there's none).
class AppAvatar extends StatelessWidget {
  final String? url;
  final String? name;
  final double size;
  final Color? backgroundColor;
  final Color? initialColor;

  const AppAvatar({
    super.key,
    required this.size,
    this.url,
    this.name,
    this.backgroundColor,
    this.initialColor,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = url;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final fallback = _Fallback(
      name: name,
      size: size,
      color: initialColor ?? AppColors.accentHot,
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.accentSoft,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image(
              image: CoverResizeImage(
                CachedNetworkImageProvider(imageUrl),
                shortestSide: (size * MediaQuery.devicePixelRatioOf(context))
                    .ceil(),
              ),
              width: size,
              height: size,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => fallback,
            )
          : fallback,
    );
  }
}

class _Fallback extends StatelessWidget {
  final String? name;
  final double size;
  final Color color;

  const _Fallback({
    required this.name,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final value = name?.trim() ?? '';
    if (value.isEmpty) {
      return Center(
        child: Icon(Icons.person_rounded, size: size * 0.5, color: color),
      );
    }
    return Center(
      child: Text(
        value.characters.first.toUpperCase(),
        // The letter is sized to the circle, so it must not grow with the
        // system text scale and spill out of it.
        textScaler: TextScaler.noScaling,
        style: TextStyle(
          color: color,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}
