import 'package:cached_network_image/cached_network_image.dart';
import 'package:car_social_media_app/core/theme/app_colors.dart';
import 'package:car_social_media_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/map_event_attendee.dart';

/// The overlapping avatar row plus "N going".
///
/// [total] is the event's own `attendees_count`, not `attendees.length` — the
/// preview only holds the first handful, and the count has to be the real one.
class MapEventAttendeeStack extends StatelessWidget {
  final List<MapEventAttendeeEntity> attendees;
  final int total;

  /// How many avatars show before the "+N" bubble.
  final int maxAvatars;

  final double size;

  const MapEventAttendeeStack({
    super.key,
    required this.attendees,
    required this.total,
    this.maxAvatars = 5,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (attendees.isEmpty && total == 0) return const SizedBox.shrink();

    final shown = attendees.take(maxAvatars).toList();
    final overflow = total - shown.length;
    // Avatars overlap by a third of their width, which is enough to read as a
    // stack without hiding the faces.
    final step = size * 0.68;

    return Row(
      children: [
        SizedBox(
          width: shown.isEmpty
              ? 0
              : step * (shown.length - 1) + size + (overflow > 0 ? step : 0),
          height: size,
          child: Stack(
            children: [
              for (var i = 0; i < shown.length; i++)
                Positioned(
                  left: step * i,
                  child: _Avatar(attendee: shown[i], size: size),
                ),
              if (overflow > 0)
                Positioned(
                  left: step * shown.length,
                  child: _OverflowBubble(count: overflow, size: size),
                ),
            ],
          ),
        ),
        if (shown.isNotEmpty) const SizedBox(width: 10),
        Flexible(
          child: Text(
            l10n.mapEventsGoingCount(total),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.ink2,
            ),
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final MapEventAttendeeEntity attendee;
  final double size;

  const _Avatar({required this.attendee, required this.size});

  @override
  Widget build(BuildContext context) {
    final url = attendee.avatarUrl;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accentSoft,
        // The ring is what separates one avatar from the one it overlaps.
        border: Border.all(color: AppColors.surface, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: (url == null || url.isEmpty)
          ? Center(
              child: Text(
                _initial(attendee.username),
                style: TextStyle(
                  fontSize: size * 0.42,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                ),
              ),
            )
          : CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
    );
  }

  static String _initial(String username) =>
      username.isEmpty ? '?' : username.characters.first.toUpperCase();
}

class _OverflowBubble extends StatelessWidget {
  final int count;
  final double size;

  const _OverflowBubble({required this.count, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.bg,
        border: Border.all(color: AppColors.surface, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        '+$count',
        style: TextStyle(
          fontSize: size * 0.32,
          fontWeight: FontWeight.w800,
          color: AppColors.mute,
        ),
      ),
    );
  }
}
