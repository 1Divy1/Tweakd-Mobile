import 'dart:ui';

import 'package:tweakd/features/map_events/presentation/widgets/popup/map_event_popup.dart';
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
import '../../../../core/shared/layout/app_layout.dart';

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
        // The map stays full-bleed; the chrome and cards over it don't.
        final sideInset = AppLayout.insetFor(
          MediaQuery.sizeOf(context).width,
          maxWidth: AppLayout.formWidth,
        );

        return Stack(
          children: [
            // Blurs the map behind whichever popup is open, so attention goes
            // to the floating card instead of the pins and roads still moving
            // underneath it. First child in the stack: everything painted
            // after it (chrome, popup) stays crisp on top.
            Positioned.fill(
              child: _MapPopupBackdrop(visible: state.isPopupOpen),
            ),

            // Back button, search pill (opens /map/search, see MapTopBar) and
            // create-event button. On a tablet the row keeps a form-width
            // measure so the buttons stay within thumb reach.
            Positioned(
              top: topInset + 4,
              left: 12 + sideInset,
              right: 12 + sideInset,
              child: Row(
                children: [
                  AppPillButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => context.pop(),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(child: MapTopBar()),
                ],
              ),
            ),

            // Error banner
            if (errorCode != null)
              Positioned(
                left: 12 + sideInset,
                right: 12 + sideInset,
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
            // The map stays full-bleed; the popup is a card, so on a tablet it
            // keeps a form-width measure instead of spanning the screen.
            Positioned(
              left: 12 + sideInset,
              right: 12 + sideInset,
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

/// The blur-and-dim layer behind an open popup.
///
/// Only mounted while a popup is open or fading out — a `BackdropFilter` costs
/// a blur pass every frame it's in the tree, and the map is visible without
/// one the overwhelming majority of the time. `IgnorePointer` keeps it purely
/// visual: taps still reach the map underneath, so tapping empty map still
/// dismisses the popup exactly as it did before this layer existed.
class _MapPopupBackdrop extends StatefulWidget {
  final bool visible;

  const _MapPopupBackdrop({required this.visible});

  @override
  State<_MapPopupBackdrop> createState() => _MapPopupBackdropState();
}

class _MapPopupBackdropState extends State<_MapPopupBackdrop> {
  late bool _mounted = widget.visible;

  @override
  void didUpdateWidget(covariant _MapPopupBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible) setState(() => _mounted = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_mounted) return const SizedBox.shrink();

    return IgnorePointer(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: widget.visible ? 1 : 0,
        onEnd: () {
          if (!widget.visible && mounted) setState(() => _mounted = false);
        },
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(color: Colors.black.withValues(alpha: 0.18)),
        ),
      ),
    );
  }
}
