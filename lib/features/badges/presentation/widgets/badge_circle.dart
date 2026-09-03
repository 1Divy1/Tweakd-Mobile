import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/badge.dart';
import 'badge_art.dart';

/// One badge in the profile strip: the artwork itself, with the badge's title
/// underneath.
///
/// No plate behind it — the artwork is a designed SVG that carries its own
/// shape and colour, and it sits straight on the page.
class BadgeCircle extends StatelessWidget {
  final BadgeEntity badge;
  final double diameter;
  final VoidCallback onTap;

  const BadgeCircle({
    super.key,
    required this.badge,
    required this.diameter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _BadgeSlot(
      diameter: diameter,
      onTap: onTap,
      caption: badge.title,
      captionColor: AppColors.mute,
      child: BadgeArt(badge: badge, size: diameter),
    );
  }
}

/// The trailing "see everything" slot. Shows `+N` when the strip had to hide
/// earned badges, and always opens the full sheet.
class BadgeOverflowCircle extends StatelessWidget {
  final int hiddenCount;
  final double diameter;
  final String label;
  final VoidCallback onTap;

  const BadgeOverflowCircle({
    super.key,
    required this.hiddenCount,
    required this.diameter,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _BadgeSlot(
      diameter: diameter,
      onTap: onTap,
      border: Border.all(color: AppColors.line, width: 1.5),
      caption: label,
      captionColor: AppColors.muteSoft,
      child: hiddenCount > 0
          ? Text(
              '+$hiddenCount',
              style: TextStyle(
                color: AppColors.mute,
                fontSize: diameter * 0.26,
                fontWeight: FontWeight.w800,
              ),
            )
          : Icon(
              Icons.more_horiz_rounded,
              size: diameter * 0.4,
              color: AppColors.mute,
            ),
    );
  }
}

/// Shared chrome for both slot kinds: the artwork box, the caption, and the
/// tap target that spans them. [border] draws an outline (the overflow slot
/// needs one to read as a control); a badge passes neither and sits bare.
class _BadgeSlot extends StatelessWidget {
  final double diameter;
  final BoxBorder? border;
  final String caption;
  final Color captionColor;
  final Widget child;
  final VoidCallback onTap;

  const _BadgeSlot({
    required this.diameter,
    required this.caption,
    required this.captionColor,
    required this.child,
    required this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: diameter,
            height: diameter,
            alignment: Alignment.center,
            decoration: border == null
                ? null
                : BoxDecoration(shape: BoxShape.circle, border: border),
            child: child,
          ),
          const SizedBox(height: 8),
          Text(
            caption.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: captionColor,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
