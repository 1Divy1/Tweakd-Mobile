import 'package:car_social_media_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// The two segments of the event page.
enum MapEventTab { overview, cars }

/// The segmented control under the stat tiles.
///
/// The active segment is a white pill on the cream track — the same treatment
/// the profile's section tabs use, so the app has one idea of what a segmented
/// control looks like.
class MapEventTabs extends StatelessWidget {
  final MapEventTab active;
  final ValueChanged<MapEventTab> onChanged;
  final String overviewLabel;
  final String carsLabel;

  const MapEventTabs({
    super.key,
    required this.active,
    required this.onChanged,
    required this.overviewLabel,
    required this.carsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Segment(
              label: overviewLabel,
              isActive: active == MapEventTab.overview,
              onTap: () => onChanged(MapEventTab.overview),
            ),
          ),
          Expanded(
            child: _Segment(
              label: carsLabel,
              isActive: active == MapEventTab.cars,
              onTap: () => onChanged(MapEventTab.cars),
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isActive,
      child: Material(
        color: isActive ? AppColors.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Container(
            height: 40,
            alignment: Alignment.center,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: isActive ? AppColors.ink : AppColors.mute,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
