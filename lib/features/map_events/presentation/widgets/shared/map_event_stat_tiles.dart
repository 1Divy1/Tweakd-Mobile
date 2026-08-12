import 'package:car_social_media_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// One of the three counters under an event's header: a glyph, a big value and
/// an uppercase caption.
///
/// [isHighlighted] turns the value accent-orange — that's how the design marks
/// the cars tile when the viewer has a car of their own on the entry list.
class MapEventStatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isHighlighted;

  const MapEventStatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final tone = isHighlighted ? AppColors.accent : AppColors.ink;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: tone),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: tone,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
              color: AppColors.mute,
            ),
          ),
        ],
      ),
    );
  }
}

/// The row of three tiles. Equal widths so the numbers line up however long
/// they get.
class MapEventStatRow extends StatelessWidget {
  final List<Widget> tiles;

  const MapEventStatRow({super.key, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: tiles[i]),
        ],
      ],
    );
  }
}
