import 'package:tweakd/features/map_events/presentation/bloc/event_detail/bloc.dart';
import 'package:tweakd/features/map_events/presentation/bloc/event_detail/event.dart';
import 'package:tweakd/features/map_events/presentation/bloc/event_detail/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' show MapboxMap;

import '../../../../core/theme/app_colors.dart';
import '../bloc/map/bloc.dart';
import '../bloc/map/event.dart';
import '../bloc/map/state.dart';
import '../widgets/map_flutter_overlays.dart';
import '../widgets/map_layer_controller.dart';
import '../widgets/map_view.dart';

/// The virtual map tab.
///
/// The map runs full-bleed, unlike the `Column` + `AppBottomNav` layout the
/// other tabs use — a map wants every pixel.
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
      onPinTapped: (kind, id) {
        if (!mounted) return;
        switch (kind) {
          case MapPinKind.business:
            context.read<MapBloc>().add(MapBusinessSelected(id));
          case MapPinKind.event:
            context.read<MapBloc>().add(MapEventPinSelected(id));
            context.read<MapEventDetailBloc>().add(LoadMapEvent(id));
        }
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
    if (command != null) {
      await layers.flyTo(command.target, zoom: command.zoom);
    }
    await layers.setLocationPuckEnabled(state.hasDeviceLocation);
    await layers.setBusinesses(
      state.visibleBusinesses,
      selectedId: state.selectedBusinessId,
      centre: state.fetchCentre,
    );
    await layers.setEvents(
      state.visibleEvents,
      selectedId: state.selectedEventId,
      centre: state.fetchCentre,
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
    final chromeBottom = bottomInset;

    return Scaffold(
      backgroundColor: AppColors.bg,
      // Side effects only: bloc state is pushed into the native map, never
      // rendered by rebuilding it. It wraps the Stack rather than sitting
      // inside it — a zero-size listener child is still a *non-positioned*
      // child, and a Stack sizes itself to those, which collapsed the whole
      // map to 0x0 under the Scaffold's loose constraints.
      body: MultiBlocListener(
        listeners: [
          // Trigger: if the list of businesses is different (a - old state, b - new state)
          // or the searched-for business came or went
          // Action: update the list with b's state
          // Notes: selectedBusinessId remains untouched; the listenWhen doesn't care about it.
          // Compares the inputs, not visibleBusinesses: that getter builds a
          // fresh list whenever a search pin is set, so it never compares equal.
          BlocListener<MapBloc, MapState>(
            listenWhen: (a, b) =>
                a.businesses != b.businesses ||
                a.searchBusiness != b.searchBusiness,
            listener: (context, state) => _layers?.setBusinesses(
              state.visibleBusinesses,
              selectedId: state.selectedBusinessId,
              centre: state.fetchCentre,
            ),
          ),
          // Trigger: the events layer changed (new fetch, a popup action
          // patched a pin's counters, or the searched-for event came or went —
          // for a past event that's the only way it gets a pin).
          BlocListener<MapBloc, MapState>(
            listenWhen: (a, b) =>
                a.events != b.events || a.searchEvent != b.searchEvent,
            listener: (context, state) => _layers?.setEvents(
              state.visibleEvents,
              selectedId: state.selectedEventId,
              centre: state.fetchCentre,
            ),
          ),
          // Trigger: the user selects a different pin (of either kind)
          // Action: move the highlight. Both ids go in together because
          // selection is mutually exclusive — opening one popup closes the
          // other, and that's two source updates in one gesture.
          BlocListener<MapBloc, MapState>(
            listenWhen: (a, b) =>
                a.selectedBusinessId != b.selectedBusinessId ||
                a.selectedEventId != b.selectedEventId,
            listener: (context, state) => _layers?.setSelected(
              businessId: state.selectedBusinessId,
              eventId: state.selectedEventId,
            ),
          ),
          // Trigger: a fresh camera command (seq bump — the target may repeat).
          // Action: flies the native camera to the command's target.
          // Notes: only catches commands emitted after this listener is
          // mounted; _onMapReady replays whatever command already landed
          // while the style was still loading, since a slow style load can
          // delay the map past MapStarted resolving a position.
          BlocListener<MapBloc, MapState>(
            listenWhen: (a, b) => a.cameraCommand != b.cameraCommand,
            listener: (context, state) {
              final command = state.cameraCommand;
              if (command != null) {
                _layers?.flyTo(command.target, zoom: command.zoom);
              }
            },
          ),
          // Trigger: hasDeviceLocation flips (fix granted/lost via MapStarted
          // or a recentre request).
          // Action: shows or hides the blue location puck.
          BlocListener<MapBloc, MapState>(
            listenWhen: (a, b) => a.hasDeviceLocation != b.hasDeviceLocation,
            listener: (context, state) =>
                _layers?.setLocationPuckEnabled(state.hasDeviceLocation),
          ),
          // Trigger: the open popup's counters changed — the viewer RSVP'd or
          // registered a car without leaving the map.
          // Action: patch the pin's own copy so the two agree. Cheaper and
          // steadier than refetching the whole nearby ring for one number.
          BlocListener<MapEventDetailBloc, MapEventDetailState>(
            listenWhen: (a, b) =>
                b.event != null &&
                (a.event?.attendeesCount != b.event?.attendeesCount ||
                    a.event?.attendingCarsCount != b.event?.attendingCarsCount),
            listener: (context, state) {
              final event = state.event!;
              context.read<MapBloc>().add(MapEventPinRefreshed(
                    eventId: event.id,
                    attendeesCount: event.attendeesCount,
                    attendingCarsCount: event.attendingCarsCount,
                  ));
            },
          ),
        ],
        // Every child below is positioned, so the Stack takes the biggest size
        // the Scaffold allows. `expand` states that intent instead of leaving
        // it to depend on there being no non-positioned child.
        child: Stack(
          fit: StackFit.expand,
          children: [
            MapView(onMapReady: _onMapReady, onMapIdle: _onMapIdle),
            MapFlutterOverlays(chromeBottom: chromeBottom),
          ],
        ),
      ),
    );
  }
}
