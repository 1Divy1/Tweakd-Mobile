import 'package:flutter/material.dart';

import '../../../domain/entities/contest_enums.dart';

/// The glyph for a contest category. Material icons rather than the mock's
/// hand-drawn strokes: same visual weight, no asset pipeline, and they scale
/// with text like everything else in the app.
class ContestCategoryGlyph extends StatelessWidget {
  final ContestCategoryIcon icon;
  final Color color;
  final double size;

  const ContestCategoryGlyph({
    super.key,
    required this.icon,
    required this.color,
    this.size = 16,
  });

  static IconData dataFor(ContestCategoryIcon icon) => switch (icon) {
        ContestCategoryIcon.exhaust => Icons.air_rounded,
        ContestCategoryIcon.wheels => Icons.tire_repair_rounded,
        ContestCategoryIcon.paint => Icons.water_drop_rounded,
        ContestCategoryIcon.interior => Icons.event_seat_rounded,
        ContestCategoryIcon.loud => Icons.volume_up_rounded,
        ContestCategoryIcon.trophy => Icons.emoji_events_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Icon(dataFor(icon), size: size, color: color);
  }
}
