import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/badge.dart';

/// A badge's artwork, fetched as an SVG from the URL the backend resolved.
///
/// Only ever the unlocked artwork — locked badges are not shown anywhere in
/// the app. Two things can go wrong and both degrade to something drawable: a
/// missing URL or a failed fetch falls back to a generic medal, and while the
/// SVG is in flight the slot holds its shape with a soft disc — so the strip
/// never reflows once the art lands.
class BadgeArt extends StatelessWidget {
  final BadgeEntity badge;
  final double size;

  const BadgeArt({super.key, required this.badge, required this.size});

  @override
  Widget build(BuildContext context) {
    final url = badge.unlockedUrl;
    if (url.isEmpty) return _fallback();

    return SvgPicture.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticsLabel: badge.title,
      placeholderBuilder: (_) => _placeholder(),
      errorBuilder: (_, _, _) => _fallback(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.line,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _fallback() {
    return Icon(
      Icons.workspace_premium_rounded,
      size: size,
      color: AppColors.mute,
    );
  }
}
