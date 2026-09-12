import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The "Tweakd." brand wordmark, drawn from the logo SVG.
///
/// The source art is a square canvas with the wordmark sitting in a band
/// across the middle, so it doubles as a splash/icon mark. Rendering it
/// inline would drag along all that empty space, so it's rendered oversized
/// and clipped back to just the glyph band — [height] is the height of the
/// wordmark itself.
///
/// Light theme only: the app has no dark theme yet. The splash screens are
/// the one place already prepared for it.
class TweakdWordmark extends StatelessWidget {
  final double height;

  const TweakdWordmark({super.key, required this.height});

  // Glyph bounds within the source SVG's 1500x1500 viewBox: the wordmark
  // spans y 624.7..860.4 and x 75.3..1425.7.
  static const double _bandHeightFraction = 235.7 / 1500;
  static const double _bandWidthFraction = 1350.5 / 1500;

  @override
  Widget build(BuildContext context) {
    final canvas = height / _bandHeightFraction;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final logoAsset = isDark
        ? 'assets/app_logo/Tweakd SVG logo transparent - Dark version.svg'
        : 'assets/app_logo/Tweakd SVG logo transparent - Light version.svg';

    return SizedBox(
      width: canvas * _bandWidthFraction,
      height: height,
      child: ClipRect(
        child: OverflowBox(
          minWidth: canvas,
          maxWidth: canvas,
          minHeight: canvas,
          maxHeight: canvas,
          child: SvgPicture.asset(logoAsset, width: canvas, height: canvas),
        ),
      ),
    );
  }
}
