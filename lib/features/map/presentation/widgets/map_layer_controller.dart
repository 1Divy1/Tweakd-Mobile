import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../domain/entities/business_pin_entity.dart';
import '../../domain/entities/geo_position.dart';
import '../utils/business_marker_factory.dart';

/// The imperative bridge between [MapState] and the native map.
///
/// This is the one place in the app where state doesn't drive a rebuild.
/// [MapboxMap] is a native controller: re-creating the `MapWidget` on every
/// state change would reload the style, refetch tiles, cost a billable map load
/// and flicker. So the page's `BlocListener` *pushes* state in here instead,
/// and the widget tree above the map never changes.
///
/// Only this file and its neighbours know Mapbox exists — entities stay free of
/// `mapbox_maps_flutter`, and the entity → GeoJSON conversion lives here.
class MapLayerController {
  MapLayerController(this._map, {BusinessMarkerFactory? markerFactory})
      : _markers = markerFactory ?? BusinessMarkerFactory();

  final MapboxMap _map;
  final BusinessMarkerFactory _markers;

  static const _sourceId = 'businesses';
  static const _layerId = 'businesses-pins';
  static const _placeholderImageId = 'business-pin-placeholder';

  /// How many logos are fetched at once. Enough to fill a screen quickly
  /// without opening 200 sockets on a phone connection.
  static const _logoBatchSize = 8;

  /// Style image ids already registered, so panning back over a business never
  /// re-downloads its logo.
  final Set<String> _loadedLogoIds = {};

  List<BusinessPinEntity> _businesses = const [];
  String? _selectedId;

  bool _installed = false;
  bool _disposed = false;

  /// Guards against a second logo pass starting while one is still running.
  int _logoPass = 0;

  /// Adds the source, the pin layer and the tap handler. Safe to call again
  /// after a style reload — everything is rebuilt from the cached state.
  ///
  /// [onBusinessTapped] fires when a pin is hit, [onMapTapped] when the tap
  /// lands anywhere else (which is how the popup gets dismissed).
  Future<void> installLayers({
    required ValueChanged<String> onBusinessTapped,
    required VoidCallback onMapTapped,
  }) async {
    if (_disposed) return;

    // Non-fatal on purpose. This is the first await in the install, so an
    // exception here used to take the source, the layer and the tap handler
    // down with it — a marker that won't register should cost us pins, not the
    // whole map.
    try {
      final placeholder = await _markers.buildPlaceholderMarker();
      if (_disposed) return;
      await _map.style.addStyleImage(
        _placeholderImageId,
        BusinessMarkerFactory.scale,
        placeholder,
        false,
        [],
        [],
        null,
      );
    } catch (e) {
      debugPrint('Failed to register the placeholder marker: $e');
    }
    if (_disposed) return;

    await _map.style.addSource(
      GeoJsonSource(id: _sourceId, data: _emptyCollection),
    );

    await _map.style.addLayer(
      SymbolLayer(
        id: _layerId,
        sourceId: _sourceId,
        // Per-business icon: each pin points at its own logo image, falling
        // back to the shared placeholder until that logo has been registered.
        iconImageExpression: ['get', 'icon_id'],
        // The selected pin grows slightly so the popup has a visible anchor.
        iconSizeExpression: [
          'case',
          ['get', 'selected'],
          1.18,
          1.0,
        ],
        iconAnchor: IconAnchor.CENTER,
        // Left false on purpose: Mapbox then hides colliding pins for us,
        // which is the cheapest possible decluttering in a dense city centre.
        iconAllowOverlap: false,
        iconIgnorePlacement: false,
        // Lower sort key wins a collision — nearest businesses survive, and
        // the selected one always does.
        symbolSortKeyExpression: ['get', 'sort_key'],
      ),
    );

    // One map-wide tap handler that asks the renderer what was hit, rather
    // than a pin interaction plus a separate dismiss interaction. Two
    // interactions would depend on Mapbox's evaluation order to decide which
    // one wins a tap on a pin; this can't get that wrong.
    _map.addInteraction(
      TapInteraction.onMap((context) async {
        final id = await _businessIdAt(context.touchPosition);
        if (_disposed) return;
        if (id != null) {
          onBusinessTapped(id);
        } else {
          onMapTapped();
        }
      }),
      interactionID: 'map-tap',
    );

    _installed = true;

    // A style reload wipes sources and layers; replay whatever the bloc last
    // pushed so the map comes back with its pins.
    if (_businesses.isNotEmpty) {
      await setBusinesses(_businesses, selectedId: _selectedId);
    }
  }

  /// Replaces the pins on the map.
  ///
  /// Pins appear immediately with the placeholder marker; logos stream in
  /// afterwards and the source is re-pushed as each batch registers. That way a
  /// slow CDN delays the logos, never the map.
  Future<void> setBusinesses(
    List<BusinessPinEntity> businesses, {
    String? selectedId,
  }) async {
    _businesses = businesses;
    _selectedId = selectedId;
    if (!_installed || _disposed) return;

    await _pushSource();
    await _loadLogos(businesses);
  }

  /// Highlights [id] (or clears the highlight when null) without refetching.
  Future<void> setSelected(String? id) async {
    if (_selectedId == id) return;
    _selectedId = id;
    if (!_installed || _disposed) return;
    await _pushSource();
  }

  /// Shows or hides the blue location puck. Only enabled once a real fix has
  /// been granted — turning it on without permission makes the native SDK
  /// raise its own prompt, competing with the app's.
  Future<void> setLocationPuckEnabled(bool enabled) async {
    if (_disposed) return;
    await _map.location.updateSettings(
      LocationComponentSettings(enabled: enabled, puckBearingEnabled: enabled),
    );
  }

  /// Animates the camera to [target].
  Future<void> flyTo(GeoPosition target, {double zoom = 12.5}) async {
    if (_disposed) return;
    await _map.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(target.lng, target.lat)),
        zoom: zoom,
      ),
      MapAnimationOptions(duration: 1200),
    );
  }

  /// Where the camera is currently pointing — read on map idle to decide
  /// whether a refetch is warranted.
  Future<GeoPosition?> currentCentre() async {
    if (_disposed) return null;
    try {
      final camera = await _map.getCameraState();
      final coordinates = camera.center.coordinates;
      return GeoPosition(
        lat: coordinates.lat.toDouble(),
        lng: coordinates.lng.toDouble(),
      );
    } catch (e) {
      debugPrint('MapLayerController.currentCentre failed: $e');
      return null;
    }
  }

  /// The business id of the pin under [point], or null if the tap missed.
  ///
  /// Queried as a small box rather than a single pixel so a slightly-off tap
  /// still lands. Symbols hidden by collision aren't rendered, so they're
  /// correctly untappable.
  Future<String?> _businessIdAt(ScreenCoordinate point) async {
    const tolerance = 12.0;

    try {
      final results = await _map.queryRenderedFeatures(
        RenderedQueryGeometry.fromScreenBox(
          ScreenBox(
            min: ScreenCoordinate(x: point.x - tolerance, y: point.y - tolerance),
            max: ScreenCoordinate(x: point.x + tolerance, y: point.y + tolerance),
          ),
        ),
        RenderedQueryOptions(layerIds: [_layerId], filter: null),
      );

      for (final result in results) {
        final properties = result?.queriedFeature.feature['properties'];
        if (properties is Map) {
          final id = properties['id'];
          if (id is String) return id;
        }
      }
    } catch (e) {
      debugPrint('MapLayerController._businessIdAt failed: $e');
    }
    return null;
  }

  Future<void> _pushSource() async {
    try {
      final source = await _map.style.getSource(_sourceId);
      if (source is GeoJsonSource) {
        await source.updateGeoJSON(_buildGeoJson());
      }
    } catch (e) {
      debugPrint('MapLayerController._pushSource failed: $e');
    }
  }

  /// GeoJSON is **longitude-first**. [GeoPosition] exists so this is the only
  /// place the order has to be got right.
  String _buildGeoJson() {
    final features = [
      for (final b in _businesses)
        {
          'type': 'Feature',
          'id': b.id,
          'geometry': {
            'type': 'Point',
            'coordinates': [b.position.lng, b.position.lat],
          },
          'properties': {
            'id': b.id,
            'icon_id': _loadedLogoIds.contains(b.id)
                ? _logoImageId(b.id)
                : _placeholderImageId,
            'selected': b.id == _selectedId,
            'sort_key': b.id == _selectedId ? -1.0 : b.distanceKm,
          },
        },
    ];

    return jsonEncode({'type': 'FeatureCollection', 'features': features});
  }

  Future<void> _loadLogos(List<BusinessPinEntity> businesses) async {
    final pending = [
      for (final b in businesses)
        if (b.logoUrl.isNotEmpty && !_loadedLogoIds.contains(b.id)) b,
    ];
    if (pending.isEmpty) return;

    final pass = ++_logoPass;

    for (var i = 0; i < pending.length; i += _logoBatchSize) {
      if (_disposed || pass != _logoPass) return;

      final batch = pending.skip(i).take(_logoBatchSize).toList();
      final images = await Future.wait(
        batch.map((b) => _markers.buildLogoMarker(b.logoUrl)),
      );
      if (_disposed || pass != _logoPass) return;

      var registered = false;
      for (var j = 0; j < batch.length; j++) {
        final image = images[j];
        if (image == null) continue;
        try {
          await _map.style.addStyleImage(
            _logoImageId(batch[j].id),
            BusinessMarkerFactory.scale,
            image,
            false,
            [],
            [],
            null,
          );
          _loadedLogoIds.add(batch[j].id);
          registered = true;
        } catch (e) {
          debugPrint('Failed to register logo for ${batch[j].id}: $e');
        }
      }

      // Only re-push once per batch: the pins that just got a logo swap from
      // the placeholder to their own image.
      if (registered && !_disposed && pass == _logoPass) await _pushSource();
    }
  }

  static String _logoImageId(String businessId) => 'business-logo-$businessId';

  static const _emptyCollection =
      '{"type":"FeatureCollection","features":[]}';

  void dispose() {
    _disposed = true;
    _markers.dispose();
  }
}
