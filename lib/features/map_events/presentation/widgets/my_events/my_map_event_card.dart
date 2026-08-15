import 'package:car_social_media_app/core/theme/app_colors.dart';
import 'package:car_social_media_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/map_event_enums.dart';
import '../../../domain/entities/map_event_summary.dart';
import '../../utils/map_event_formatting.dart';
import '../shared/map_event_chips.dart';
import '../shared/map_event_cover.dart';

/// A row in "My events".
///
/// The approval badge is the reason this card exists rather than reusing the
/// map's preview: a creator's list is mostly about *whether the event got
/// through*, so pending and rejected states — and the rejection reason — sit
/// above everything else.
class MyMapEventCard extends StatelessWidget {
  final MapEventSummaryEntity event;

  const MyMapEventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final reason = event.rejectionReason;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/map-events/${event.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                MapEventCover(
                  imageUrl: event.coverImageUrl,
                  height: 120,
                  withScrim: false,
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: MapEventStatusChip(status: event.status),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: MapEventApprovalChip(approval: event.approvalStatus),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _MetaLine(
                    icon: Icons.place_outlined,
                    text: event.locationName,
                  ),
                  const SizedBox(height: 5),
                  _MetaLine(
                    icon: Icons.schedule_rounded,
                    text: MapEventFormat.dateRange(
                      context,
                      event.startsAt,
                      event.endsAt,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _Counter(
                        icon: Icons.people_alt_rounded,
                        value: event.attendeesCount,
                      ),
                      const SizedBox(width: 14),
                      _Counter(
                        icon: Icons.directions_car_rounded,
                        value: event.attendingCarsCount,
                      ),
                    ],
                  ),
                  // Only rejected events carry a reason, and it's the single
                  // most useful thing on the card when they do.
                  if (event.approvalStatus == MapEventApproval.rejected &&
                      reason != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: AppColors.accentSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n.mapEventsRejectionReason(reason),
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.35,
                          color: AppColors.accentHot,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.mute),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: AppColors.ink2),
          ),
        ),
      ],
    );
  }
}

class _Counter extends StatelessWidget {
  final IconData icon;
  final int value;

  const _Counter({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.muteSoft),
        const SizedBox(width: 5),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.mute,
          ),
        ),
      ],
    );
  }
}
