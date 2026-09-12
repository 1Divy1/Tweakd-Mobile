import 'package:cached_network_image/cached_network_image.dart';
import 'package:tweakd/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// An event's cover photo, with the dark bottom gradient that lets white text
/// sit over it whatever the photo happens to be.
///
/// Falls back to a flat accent-tinted panel with a car glyph when there's no
/// cover — several events won't have one, and an empty grey box next to a
/// photographed one looks broken rather than plain.
class MapEventCover extends StatelessWidget {
  final String? imageUrl;
  final double height;

  /// Whether to paint the scrim. Off for thumbnails that carry no text.
  final bool withScrim;

  const MapEventCover({
    super.key,
    required this.imageUrl,
    required this.height,
    this.withScrim = true,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (url == null || url.isEmpty)
            const _CoverFallback()
          else
            CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (_, _) => ColoredBox(color: AppColors.line2),
              errorWidget: (_, _, _) => const _CoverFallback(),
            ),
          if (withScrim)
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  // Two stops rather than a straight fade: the top stays clear
                  // for the status chip and the back button, and the bottom
                  // goes dark enough for a title to be legible over a bright
                  // sky.
                  colors: [
                    Color(0x33000000),
                    Color(0x00000000),
                    Color(0xB3000000),
                  ],
                  stops: [0.0, 0.35, 1.0],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.accentSoft,
      child: Center(
        child: Icon(
          Icons.directions_car_rounded,
          size: 40,
          color: AppColors.accent,
        ),
      ),
    );
  }
}
