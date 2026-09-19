import 'package:flutter/material.dart';
import 'package:tweakd/features/map_events/domain/entities/map_event_enums.dart';
import 'package:tweakd/l10n/app_localizations.dart';

import '../../../../../core/theme/app_colors.dart';

/// The Live / Upcoming / Past filter over the Events tab. Multi-select; the
/// bloc refuses to turn the last one off, so at least one always stays on.
class MapSearchStatusChips extends StatelessWidget {
  final Set<MapEventStatus> selected;
  final ValueChanged<MapEventStatus> onToggle;

  const MapSearchStatusChips({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  static const _order = [
    MapEventStatus.live,
    MapEventStatus.upcoming,
    MapEventStatus.previous,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Wrap, not Row: three labels at a large text scale or in Romanian must be
    // able to drop to a second line instead of overflowing.
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final status in _order)
          _StatusChip(
            label: switch (status) {
              MapEventStatus.live => l10n.mapSearchStatusLive,
              MapEventStatus.upcoming => l10n.mapSearchStatusUpcoming,
              _ => l10n.mapSearchStatusPast,
            },
            showLiveDot: status == MapEventStatus.live,
            selected: selected.contains(status),
            onTap: () => onToggle(status),
          ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool showLiveDot;
  final bool selected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.showLiveDot,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.ink : AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showLiveDot) ...[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? AppColors.inkPanel : AppColors.ink2,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
