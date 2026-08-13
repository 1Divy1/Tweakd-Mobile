import 'package:car_social_media_app/features/map_events/presentation/widgets/popup/map_event_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/app_pill_button.dart';
import '../bloc/map/bloc.dart';
import '../bloc/map/event.dart';
import '../bloc/map/state.dart';
import 'businesses/business_popup.dart';
import 'map_error_banner.dart';
import 'map_recentre_button.dart';
import 'map_top_bar.dart';

/// Everything drawn *over* the map: the top bar, error banner, recentre button
/// and whichever popup is open. Split out so the map surface itself stays out
/// of the rebuild path.
class MapFlutterOverlays extends StatelessWidget {
  final double chromeBottom;

  const MapFlutterOverlays({super.key, required this.chromeBottom});

  /// Height to clear Mapbox's default bottom-right attribution ("i") icon
  /// plus its own margin, so the recentre button doesn't sit on top of it.
  static const _attributionClearance = 50.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        final bloc = context.read<MapBloc>();
        final errorCode = state.errorCode;
        final topInset = MediaQuery.paddingOf(context).top;

        return Stack(
          children: [
            // Back button
            Positioned(
              top: topInset,
              left: 12,
              child: AppPillButton(
                icon: Icons.chevron_left_rounded,
                onTap: () => context.pop(),
              ),
            ),

            // Search field + create-event button. The bar is inert by design
            // (see MapTopBar) and sits clear of the back button.
            Positioned(
              top: topInset + 4,
              left: 66,
              right: 12,
              child: const MapTopBar(),
            ),

            // Error banner
            if (errorCode != null)
              Positioned(
                left: 12,
                right: 12,
                top: topInset + 64,
                child: MapErrorBanner(
                  code: errorCode,
                  onDismiss: () => bloc.add(const MapErrorDismissed()),
                ),
              ),

            // Location recentre button
            if (!state.isPopupOpen)
              Positioned(
                right: 14,
                bottom: chromeBottom + _attributionClearance,
                child: MapRecentreButton(
                  isActive: state.hasDeviceLocation,
                  onTap: () => bloc.add(const MapRecentreRequested()),
                ),
              ),

            // The floating popup. Businesses and events are mutually exclusive
            // — the bloc clears one selection when the other is made — so a
            // single AnimatedSwitcher cross-fades between them, keyed by the
            // selected id so switching pins animates rather than mutating in
            // place.
            Positioned(
              left: 12,
              right: 12,
              bottom: chromeBottom,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.12),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: switch ((state.selectedBusinessId, state.selectedEventId)) {
                  (final businessId?, _) => BusinessPopup(
                      key: ValueKey('business-$businessId'),
                      state: state,
                      onClose: () => bloc.add(const MapBusinessDismissed()),
                      onRetry: () => bloc.add(const MapBusinessDetailRetried()),
                    ),
                  (_, final eventId?) => MapEventPopup(
                      key: ValueKey('event-$eventId'),
                      pin: state.selectedEventPin,
                      onClose: () => bloc.add(const MapBusinessDismissed()),
                    ),
                  _ => const SizedBox.shrink(),
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
