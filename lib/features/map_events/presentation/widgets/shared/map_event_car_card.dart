import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/features/garage/presentation/widgets/car_image.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/map_event_participant.dart';

/// One entry on the entry list: the car's cover photo with its name over it,
/// and a footer with the owner and a link into their garage.
///
/// The whole card and the GARAGE link go to the same place — the car's page —
/// because that *is* the owner's garage entry for it; a separate destination
/// would be two routes for one thing.
class MapEventCarCard extends StatelessWidget {
  final MapEventParticipantEntity participant;

  /// Organizer review actions. Both null on the public entry list.
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final bool isBusy;

  const MapEventCarCard({
    super.key,
    required this.participant,
    this.onAccept,
    this.onDecline,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final car = participant.car;
    final owner = car.ownerUsername;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => context.push('/garage/cars/${car.id}', extra: false),
            child: Stack(
              children: [
                CarImage(
                  imageUrl: car.coverImage?.url,
                  height: 168,
                  width: double.infinity,
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00000000), Color(0xA6000000)],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 12,
                  child: Text(
                    '${car.brand} ${car.model}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
            child: Row(
              children: [
                _OwnerAvatar(username: owner),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    owner == null ? '' : '@$owner',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink2,
                    ),
                  ),
                ),
                if (onAccept == null && onDecline == null)
                  TextButton(
                    onPressed: () =>
                        context.push('/garage/cars/${car.id}', extra: false),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      visualDensity: VisualDensity.compact,
                      textStyle: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.mapEventsGarageLink),
                        const Icon(Icons.chevron_right_rounded, size: 16),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (onAccept != null || onDecline != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  if (onDecline != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isBusy ? null : onDecline,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.ink2,
                          side: BorderSide(color: AppColors.line),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        child: Text(l10n.mapEventsDecline),
                      ),
                    ),
                  if (onAccept != null && onDecline != null)
                    const SizedBox(width: 8),
                  if (onAccept != null)
                    Expanded(
                      child: FilledButton(
                        onPressed: isBusy ? null : onAccept,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        child: Text(l10n.mapEventsAccept),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _OwnerAvatar extends StatelessWidget {
  final String? username;

  const _OwnerAvatar({required this.username});

  @override
  Widget build(BuildContext context) {
    // The participant DTO's owner is `{ id, username }` — no avatar URL — so
    // this is an initial, not a photo.
    final initial = (username == null || username!.isEmpty)
        ? '?'
        : username!.characters.first.toUpperCase();

    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.accent,
        ),
      ),
    );
  }
}
