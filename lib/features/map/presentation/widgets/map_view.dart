import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../domain/map_defaults.dart';
import '../utils/map_light_preset.dart';

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

  /// The `lightPreset` last pushed to the style; null until the style loads.
  /// Lets a live theme switch relight the map without reloading the style.
  String? _appliedLightPreset;

  /// Where `MapTopBar`'s "+" create-event button sits, in the overlay Stack's
  /// own coordinates (see `MapFlutterOverlays`): `topInset + 4` down to
  /// `+ 44` for the button itself, flush against a 12px right margin. The
  /// compass ornament's default top-right position collides with it, so it
  /// gets pushed below with a small gap instead.
  static const _createEventButtonTop = 4.0;
  static const _createEventButtonSize = 44.0;
  static const _compassGap = 8.0;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final preset = mapLightPresetFor(context);
    final map = _map;
    if (map == null || _appliedLightPreset == null) return;
    if (preset == _appliedLightPreset) return;
    _appliedLightPreset = preset;
    map.style.setStyleImportConfigProperty('basemap', 'lightPreset', preset);
  }

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

    // Read before the first `await` — using `context` after one risks it
    // having been unmounted in between.
    final topInset = MediaQuery.paddingOf(context).top;
    final lightPreset = mapLightPresetFor(context);

    // The Standard style ships 3D buildings, landmarks and real shadows; we
    // only configure it. Lighting follows the app theme, and Mapbox's own
    // POI/transit labels are hidden so that our pins (businesses, meets, roads)
    // read clearly.
    _appliedLightPreset = lightPreset;
    await map.style.setStyleImportConfigProperties('basemap', {
      'lightPreset': lightPreset,
      'show3dObjects': true,
      'showPointOfInterestLabels': false,
      'showTransitLabels': false,
    });

    // The scale bar is noise on a social map; the compass earns its place once
    // the map can be rotated away from north.
    await map.scaleBar.updateSettings(ScaleBarSettings(enabled: false));

    // Default top-right placement sits directly under the create-event "+"
    // button and gets fully covered by it — move the compass below instead.
    await map.compass.updateSettings(CompassSettings(
      position: OrnamentPosition.TOP_RIGHT,
      marginTop: topInset +
          _createEventButtonTop +
          _createEventButtonSize +
          _compassGap,
      marginRight: 12,
    ));

    if (mounted) widget.onMapReady?.call(map);
  }
}
