import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/map_event_enums.dart';
import '../../utils/map_event_formatting.dart';

/// The small status pill that sits over an event's cover image.
///
/// Upcoming is black-on-white-text and quiet; live gets the accent fill and a
/// pulsing-free dot, because "happening right now" is the one state worth
/// noticing from across a scroll.
class MapEventStatusChip extends StatelessWidget {
  final MapEventStatus status;

  const MapEventStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLive = status == MapEventStatus.live;

    return Container(
      padding: EdgeInsets.fromLTRB(isLive ? 8 : 10, 5, 10, 5),
      decoration: BoxDecoration(
        color: isLive ? AppColors.accent : AppColors.ink,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLive) ...[
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            MapEventFormat.statusLabel(l10n, status),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// The approval badge on "My events" rows. Renders nothing for an accepted
/// event — that's the normal state and doesn't need a label.
class MapEventApprovalChip extends StatelessWidget {
  final MapEventApproval approval;

  const MapEventApprovalChip({super.key, required this.approval});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = MapEventFormat.approvalLabel(l10n, approval);
    if (label == null) return const SizedBox.shrink();

    final isRejected = approval == MapEventApproval.rejected;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isRejected ? AppColors.accentSoft : AppColors.line,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: isRejected ? AppColors.accentHot : AppColors.mute,
        ),
      ),
    );
  }
}

/// `INDIVIDUAL` / `BUSINESS` next to an organizer's name.
class MapEventOrganizerTypeChip extends StatelessWidget {
  final MapEventOrganizerType type;

  const MapEventOrganizerTypeChip({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type == MapEventOrganizerType.business
            ? l10n.mapEventsChipBusiness
            : l10n.mapEventsChipIndividual,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: AppColors.mute,
        ),
      ),
    );
  }
}

/// The locked `SOON` chip on categories that exist in the design but not yet in
/// the backend.
class MapEventSoonChip extends StatelessWidget {
  const MapEventSoonChip({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.line,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        l10n.mapEventsSoon,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: AppColors.muteSoft,
        ),
      ),
    );
  }
}

/// The uppercase micro-label that heads every section of the detail page and
/// the create form.
class MapEventSectionLabel extends StatelessWidget {
  final String label;

  /// A muted suffix — `OPTIONAL` / `REQUIRED` on form sections.
  final String? trailing;

  const MapEventSectionLabel({
    super.key,
    required this.label,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.mute,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          Text(
            trailing!,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.muteSoft,
            ),
          ),
        ],
      ],
    );
  }
}
