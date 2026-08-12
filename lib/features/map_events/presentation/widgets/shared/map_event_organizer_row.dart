import 'package:cached_network_image/cached_network_image.dart';
import 'package:car_social_media_app/core/theme/app_colors.dart';
import 'package:car_social_media_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/map_event.dart';
import '../../../domain/entities/map_event_enums.dart';
import 'map_event_chips.dart';

/// One organizer of an event: avatar, name, role and an INDIVIDUAL / BUSINESS
/// chip. Business organizers are certified by definition — that's the only way
/// a business account can be added — so they carry the verified check.
///
/// **Deliberately not a link.** The design shows an `@username` line and a
/// chevron into the profile, but the backend's organizer DTO carries no
/// username, and the app's profile route is `/users/:username` (there's no
/// by-id route to fall back on). Rather than render a chevron that goes
/// nowhere, the row is inert. See `MAP_EVENTS_NOTES.md` §1.1 — adding
/// `username` to the DTO is all this needs to become the designed row.
class MapEventOrganizerRow extends StatelessWidget {
  final MapEventOrganizerEntity organizer;

  /// Shown on the create/manage screens, where an organizer can be taken off
  /// again. Null hides the affordance.
  final VoidCallback? onRemove;

  /// Marks the creator's own row in the create form ("YOU · CREATOR").
  final bool isSelf;

  const MapEventOrganizerRow({
    super.key,
    required this.organizer,
    this.onRemove,
    this.isSelf = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _OrganizerAvatar(organizer: organizer),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        organizer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    if (organizer.isBusiness) ...[
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.verified_rounded,
                        size: 15,
                        color: Colors.blue,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isSelf
                      ? l10n.mapEventsYouCreator
                      : (organizer.isCreator
                          ? l10n.mapEventsRoleCreator
                          : l10n.mapEventsRoleOrganizer),
                  style: const TextStyle(fontSize: 12, color: AppColors.mute),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded, size: 18),
              color: AppColors.mute,
              tooltip: l10n.mapEventsRemoveOrganizer,
              visualDensity: VisualDensity.compact,
            )
          else
            MapEventOrganizerTypeChip(type: organizer.type),
        ],
      ),
    );
  }
}

class _OrganizerAvatar extends StatelessWidget {
  final MapEventOrganizerEntity organizer;

  const _OrganizerAvatar({required this.organizer});

  @override
  Widget build(BuildContext context) {
    final url = organizer.imageUrl;
    // A business is a logo (square, cropped to a rounded square); a person is
    // an avatar (circle). Same treatment as everywhere else in the app.
    final radius = organizer.isBusiness ? 10.0 : 20.0;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: (url == null || url.isEmpty)
          ? Icon(
              organizer.type == MapEventOrganizerType.business
                  ? Icons.storefront_rounded
                  : Icons.person_rounded,
              size: 20,
              color: AppColors.accent,
            )
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => const Icon(
                Icons.person_rounded,
                size: 20,
                color: AppColors.accent,
              ),
            ),
    );
  }
}
