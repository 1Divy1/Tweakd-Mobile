import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../domain/map_defaults.dart';

/// The Mapbox rendering surface.
///
/// Deliberately a widget that never rebuilds from state: the [MapboxMap] handed
/// back by [MapWidget.onMapCreated] is an *imperative* native controller.
/// Rebuilding [MapWidget] would reload the style, refetch tiles and cost a
/// billable map load — so data layers (businesses, and later meets, roads and
/// live users) are pushed into the controller from a `BlocListener`, never
/// rendered by rebuilding this widget. See `lib/features/map/README.md`.
class MapView extends StatefulWidget {
  const MapView({super.key, this.onMapReady, this.onMapIdle});

  /// Called once the native map exists and its style has finished loading —
  /// the only safe point to add sources and layers.
  ///
  /// Can fire more than once: a style reload re-runs it, and every source and
  /// layer has to be reinstalled when it does.
  final ValueChanged<MapboxMap>? onMapReady;

  /// The camera stopped moving. Cheaper and steadier than debouncing
  /// `onCameraChange`, which fires every frame of a pan.
  final VoidCallback? onMapIdle;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  MapboxMap? _map;

  /// Framing before the first fix lands; the bloc flies the camera to the user
  /// (or to the fallback centre) as soon as it knows where to look. Pitch is
  /// what makes the basemap read as 3D.
  static final _initialViewport = CameraViewportState(
    center: Point(
      coordinates: Position(
        kMapFallbackCentre.lng,
        kMapFallbackCentre.lat,
      ),
    ),
    zoom: 12,
    pitch: 30,
    bearing: 0,
  );

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      key: const ValueKey('mapWidget'),
      styleUri: MapboxStyles.STANDARD,
      textureView: true,
      viewport: _initialViewport,
      onMapCreated: (map) => _map = map,
      onStyleLoadedListener: _onStyleLoaded,
      onMapIdleListener: (_) => widget.onMapIdle?.call(),
    );
  }

  Future<void> _onStyleLoaded(StyleLoadedEventData _) async {
    final map = _map;
    if (map == null) return;

    // The Standard style ships 3D buildings, landmarks and real shadows; we
    // only configure it. Mapbox's own POI/transit labels are hidden so that our
    // pins (businesses, meets, roads) read clearly.
    await map.style.setStyleImportConfigProperties('basemap', {
      'lightPreset': _lightPresetForTimeOfDay(),
      'show3dObjects': true,
      'showPointOfInterestLabels': false,
      'showTransitLabels': false,
    });

    // The scale bar is noise on a social map; the compass earns its place once
    // the map can be rotated away from north.
    await map.scaleBar.updateSettings(ScaleBarSettings(enabled: false));

    if (mounted) widget.onMapReady?.call(map);
  }

  /// Lights the map to match the user's actual time of day.
  String _lightPresetForTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 6 || hour >= 21) return 'night';
    if (hour < 8) return 'dawn';
    if (hour < 18) return 'day';
    return 'dusk';
  }
}
