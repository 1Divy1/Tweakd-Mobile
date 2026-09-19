import 'package:flutter/material.dart';
import 'package:tweakd/features/map_events/domain/entities/map_event_enums.dart';
import 'package:tweakd/features/map_events/domain/entities/map_event_pin.dart';
import 'package:tweakd/features/map_events/presentation/utils/map_event_formatting.dart';
import 'package:tweakd/features/map_events/presentation/widgets/shared/map_event_cover.dart';
import 'package:tweakd/l10n/app_localizations.dart';

import '../../../../../core/theme/app_colors.dart';

/// One event in the search results: cover thumbnail, title, when, and where.
///
/// A live event gets an accent "Live" tag — it is the one result you could
/// still drive to right now. A past one is shown at reduced emphasis: it is
/// there for looking back, not for acting on.
class MapSearchEventTile extends StatelessWidget {
  final MapEventPinEntity event;
  final VoidCallback onTap;

  const MapSearchEventTile({super.key, required this.event, required this.onTap});

  static const _thumbSize = 56.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPast = event.status == MapEventStatus.previous;
    final where = [
      event.locationName,
      event.categoryLabel,
    ].where((part) => part.isNotEmpty).join(' · ');

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Opacity(
                opacity: isPast ? 0.6 : 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: _thumbSize,
                    child: MapEventCover(
                      imageUrl: event.coverImageUrl,
                      height: _thumbSize,
                      withScrim: false,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (event.isLive) ...[
                          _LiveTag(label: l10n.mapSearchStatusLive),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            event.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isPast ? AppColors.mute : AppColors.ink,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      MapEventFormat.dateRange(context, event.startsAt, event.endsAt),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isPast ? AppColors.muteSoft : AppColors.ink2,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (where.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        where,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.muteSoft, fontSize: 12.5),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: AppColors.muteSoft, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveTag extends StatelessWidget {
  final String label;

  const _LiveTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        style: TextStyle(
          color: AppColors.onAccent,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
