import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' show MapboxMap;

import '../../../../core/shared/widgets/app_bottom_nav.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/map/bloc.dart';
import '../bloc/map/event.dart';
import '../bloc/map/state.dart';
import '../widgets/business_popup.dart';
import '../widgets/map_error_banner.dart';
import '../widgets/map_layer_controller.dart';
import '../widgets/map_recentre_button.dart';
import '../widgets/map_view.dart';

/// The virtual map tab.
///
/// The map runs full-bleed with the nav bar floating over it, rather than the
/// `Column` + `AppBottomNav` layout the other tabs use — a map wants every
/// pixel, and the nav bar's rounded top already reads as an overlay.
///
/// This is the one page in the app where state doesn't drive the main widget:
/// [MapView] never rebuilds, and [MapLayerController] pushes bloc state into
/// the native map instead. Only the chrome around it — popup, banner, buttons —
/// is built from state.
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapLayerController? _layers;

  /// Height of [AppBottomNav]: 10 + 4 + 30 icon + 6 + 3 marker + 4 + 10.
  static const _navBarHeight = 67.0;

  @override
  void dispose() {
    _layers?.dispose();
    super.dispose();
  }

  Future<void> _onMapReady(MapboxMap map) async {
    // A style reload fires this again with the same map, and takes every source
    // and layer with it — so the controller is rebuilt from scratch rather than
    // reused.
    _layers?.dispose();
    final layers = MapLayerController(map);
    _layers = layers;

    await layers.installLayers(
      onBusinessTapped: (id) {
        if (mounted) context.read<MapBloc>().add(MapBusinessSelected(id));
      },
      onMapTapped: () {
        if (mounted) context.read<MapBloc>().add(const MapBusinessDismissed());
      },
    );
    if (!mounted) return;

    // The bloc usually resolves the user's position before the style finishes
    // loading, so replay whatever it settled on — otherwise the first camera
    // command and the first page of pins arrive while there's nothing to push
    // them into, and the map sits on its placeholder framing.
    final state = context.read<MapBloc>().state;
    final command = state.cameraCommand;
    if (command != null) await layers.flyTo(command.target);
    await layers.setLocationPuckEnabled(state.hasDeviceLocation);
    await layers.setBusinesses(
      state.businesses,
      selectedId: state.selectedBusinessId,
    );
  }

  Future<void> _onMapIdle() async {
    final centre = await _layers?.currentCentre();
    if (centre == null || !mounted) return;
    context.read<MapBloc>().add(MapCameraSettled(centre));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final chromeBottom = _navBarHeight + bottomInset + 12;

    return Scaffold(
      backgroundColor: AppColors.bg,
      // Side effects only: bloc state is pushed into the native map, never
      // rendered by rebuilding it. It wraps the Stack rather than sitting
      // inside it — a zero-size listener child is still a *non-positioned*
      // child, and a Stack sizes itself to those, which collapsed the whole
      // map to 0x0 under the Scaffold's loose constraints.
      body: MultiBlocListener(
        listeners: [
          BlocListener<MapBloc, MapState>(
            listenWhen: (a, b) => a.businesses != b.businesses,
            listener: (context, state) => _layers?.setBusinesses(
              state.businesses,
              selectedId: state.selectedBusinessId,
            ),
          ),
          BlocListener<MapBloc, MapState>(
            listenWhen: (a, b) => a.selectedBusinessId != b.selectedBusinessId,
            listener: (context, state) =>
                _layers?.setSelected(state.selectedBusinessId),
          ),
          BlocListener<MapBloc, MapState>(
            listenWhen: (a, b) => a.cameraCommand != b.cameraCommand,
            listener: (context, state) {
              final command = state.cameraCommand;
              if (command != null) _layers?.flyTo(command.target);
            },
          ),
          BlocListener<MapBloc, MapState>(
            listenWhen: (a, b) => a.hasDeviceLocation != b.hasDeviceLocation,
            listener: (context, state) =>
                _layers?.setLocationPuckEnabled(state.hasDeviceLocation),
          ),
        ],
        // Every child below is positioned, so the Stack takes the biggest size
        // the Scaffold allows. `expand` states that intent instead of leaving
        // it to depend on there being no non-positioned child.
        child: Stack(
          fit: StackFit.expand,
          children: [
            MapView(onMapReady: _onMapReady, onMapIdle: _onMapIdle),

            _MapChrome(chromeBottom: chromeBottom),

            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AppBottomNav(activeTab: AppBottomNavTab.map),
            ),
          ],
        ),
      ),
    );
  }
}

/// Everything drawn *over* the map: error banner, recentre button and the
/// business popup. Split out so the map surface itself stays out of the
/// rebuild path.
class _MapChrome extends StatelessWidget {
  final double chromeBottom;

  const _MapChrome({required this.chromeBottom});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        final bloc = context.read<MapBloc>();
        final errorCode = state.errorCode;

        return Stack(
          children: [
            if (errorCode != null)
              Positioned(
                left: 12,
                right: 12,
                top: MediaQuery.paddingOf(context).top + 12,
                child: MapErrorBanner(
                  code: errorCode,
                  onDismiss: () => bloc.add(const MapErrorDismissed()),
                ),
              ),

            // Tapping the map itself closes the popup — handled natively in
            // MapLayerController, not with a Flutter barrier, so panning and
            // zooming keep working while the popup is up.
            if (!state.isPopupOpen)
              Positioned(
                right: 14,
                bottom: chromeBottom,
                child: MapRecentreButton(
                  isActive: state.hasDeviceLocation,
                  onTap: () => bloc.add(const MapRecentreRequested()),
                ),
              ),

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
                child: state.isPopupOpen
                    ? BusinessPopup(
                        key: ValueKey(state.selectedBusinessId),
                        state: state,
                        onClose: () => bloc.add(const MapBusinessDismissed()),
                        onRetry: () =>
                            bloc.add(const MapBusinessDetailRetried()),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        );
      },
    );
  }
}
