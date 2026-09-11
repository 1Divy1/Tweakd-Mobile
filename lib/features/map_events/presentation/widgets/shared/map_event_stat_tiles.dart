import 'package:tweakd/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// One of the counters inside [MapEventStatRow]: an optional glyph, a big value
/// and an uppercase caption, stacked and centred within its segment.
///
/// [isHighlighted] turns the value accent-orange — that's how the design marks
/// the cars tile when the viewer has a car of their own on the entry list.
class MapEventStatTile extends StatelessWidget {
  final IconData? icon;
  final String value;
  final String label;
  final bool isHighlighted;

  const MapEventStatTile({
    super.key,
    this.icon,
    required this.value,
    required this.label,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final tone = isHighlighted ? AppColors.accent : AppColors.ink;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: tone),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: tone,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
            color: AppColors.mute,
          ),
        ),
      ],
    );
  }
}

/// The tiles grouped into a single rounded card, each in an equal-width segment
/// separated by a hairline divider. Equal widths keep the values aligned
/// however long they get; the shared card gives the strip a visible edge on
/// both the detail page (sits on [AppColors.bg]) and the map popup (white).
class MapEventStatRow extends StatelessWidget {
  final List<Widget> tiles;

  const MapEventStatRow({super.key, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0)
              Container(width: 1, height: 30, color: AppColors.line),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: tiles[i],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
