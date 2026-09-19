import 'package:tweakd/core/analytics/analytics_events.dart';
import 'package:tweakd/core/analytics/analytics_service.dart';
import 'package:tweakd/core/deeplinks/share_link_route.dart';
import 'package:tweakd/core/di/injection.dart';
import 'package:tweakd/core/services/share_launcher_service.dart';
import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/features/garage/presentation/widgets/share/share_origin.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/map_event.dart';
import '../../../domain/entities/map_event_enums.dart';
import '../shared/map_event_chips.dart';
import '../shared/map_event_cover.dart';

/// The event page's cover header: photo, back and share buttons, status chip,
/// title and the location line.
///
/// The location line is the place name alone. It used to append a distance;
/// that was a straight line from wherever the map last fetched, which is not a
/// distance anyone can drive — see `MAP_EVENTS_NOTES.md` §2.3.
class MapEventHero extends StatelessWidget {
  final MapEventEntity event;

  const MapEventHero({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topInset = MediaQuery.paddingOf(context).top;

    return Stack(
      children: [
        MapEventCover(imageUrl: event.coverImageUrl, height: 248 + topInset),
        Positioned(
          top: topInset + 6,
          left: 12,
          right: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _HeroButton(
                icon: Icons.chevron_left_rounded,
                semanticLabel: MaterialLocalizations.of(
                  context,
                ).backButtonTooltip,
                onTap: () => context.pop(),
              ),
              if (_isShareable)
                Builder(
                  builder: (buttonContext) => _HeroButton(
                    icon: Icons.ios_share_rounded,
                    semanticLabel: l10n.mapEventsShare,
                    onTap: () => _share(buttonContext),
                  ),
                ),
            ],
          ),
        ),
        Positioned(
          left: 18,
          right: 18,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 26,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  MapEventStatusChip(status: event.status),
                ],
              ),
              if (event.locationName.isNotEmpty) ...[
                const SizedBox(height: 7),
                Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 15,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        event.locationName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Whether the public page would actually show this event. A pending or
  /// rejected event is a 404 there and a cancelled one a 410, so an organizer
  /// looking at their own submission gets no share button rather than a link
  /// that is dead on arrival.
  bool get _isShareable =>
      event.approvalStatus == MapEventApproval.accepted &&
      event.status != MapEventStatus.canceled &&
      event.status != MapEventStatus.hidden;

  /// Opens the OS share sheet (which includes Copy) with the event's public
  /// link, `web.tweakdapp.com/e/{id}`, and nothing else — so Copy yields a URL
  /// that pastes into a browser. Someone without the app gets the event
  /// page in the browser; someone with it lands straight on this screen.
  Future<void> _share(BuildContext buttonContext) async {
    final origin = shareOriginOf(buttonContext);
    getIt<AnalyticsService>().track(AnalyticsEvents.eventShareOpened);
    await getIt<ShareLauncherService>().shareLink(
      url: eventShareUrl(event.id),
      title: event.title,
      origin: origin,
    );
  }
}

class _HeroButton extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  const _HeroButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: AppColors.surface,
        shape: const CircleBorder(),
        elevation: 2,
        shadowColor: AppColors.shadowAlpha(0x33),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(icon, size: 20, color: AppColors.ink),
          ),
        ),
      ),
    );
  }
}
