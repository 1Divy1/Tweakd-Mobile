import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/badge.dart';

/// A badge's artwork, fetched as an SVG from the URL the backend resolved.
///
/// Three things can go wrong and all of them degrade to something drawable: a
/// badge with no locked variant is greyed from its unlocked art, a missing URL
/// or a failed fetch falls back to a generic medal, and while the SVG is in
/// flight the slot holds its shape with a soft disc — so the strip never
/// reflows once the art lands.
class BadgeArt extends StatelessWidget {
  final BadgeEntity badge;
  final double size;

  /// Draw the locked treatment: [BadgeEntity.lockedUrl] if the badge has one,
  /// otherwise the unlocked art desaturated and dimmed.
  final bool locked;

  const BadgeArt({
    super.key,
    required this.badge,
    required this.size,
    this.locked = false,
  });

  /// Luminance weights — the same ones used for greyscale conversion, so a
  /// bright badge dims to a mid grey rather than to black.
  static const _greyscale = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    final url = locked
        ? (badge.lockedUrl ?? badge.unlockedUrl)
        : badge.unlockedUrl;
    if (url.isEmpty) return _fallback();

    final art = SvgPicture.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticsLabel: badge.title,
      placeholderBuilder: (_) => _placeholder(),
      errorBuilder: (_, _, _) => _fallback(),
    );

    // Only fake the locked look when the backend didn't ship one.
    if (locked && badge.lockedUrl == null) {
      return ColorFiltered(
        colorFilter: _greyscale,
        child: Opacity(opacity: 0.5, child: art),
      );
    }
    return art;
  }

  Widget _placeholder() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.line,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _fallback() {
    return Icon(
      Icons.workspace_premium_rounded,
      size: size,
      color: locked ? AppColors.muteSoft : AppColors.mute,
    );
  }
}
