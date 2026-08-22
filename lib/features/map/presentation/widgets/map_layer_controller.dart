import 'dart:convert';

import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/features/map_events/domain/entities/map_event_pin.dart';
import 'package:flutter/foundation.dart';
// Named imports only: `mapbox_maps_flutter` exports its own `Point`, which
// collides with Flutter's if material is pulled in wholesale.
import 'package:flutter/material.dart' show Color, IconData, Icons;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../domain/entities/business_pin_entity.dart';
import '../../domain/entities/geo_position.dart';
import '../utils/map_marker_factory.dart';

/// Which layer a tap landed on.
enum MapPinKind { business, event }

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
///
/// Two layers ride on the same machinery: businesses (logo in a white ring) and
/// events (cover photo in a ring that turns accent-orange while the event is
/// live). Everything about them is identical except their pixels, which is why
/// [_PinLayer] carries the shared plumbing.
class MapLayerController {
  MapLayerController(this._map, {MapMarkerFactory? markerFactory})
      : _markers = markerFactory ??
            MapMarkerFactory(placeholderIcon: Icons.storefront_rounded);

  final MapboxMap _map;
  final MapMarkerFactory _markers;

  /// Events are drawn above businesses and win a tap that hits both, which
  /// matches how they read visually: a meet is an occasion, a shop is scenery.
  static const _businessLayer = _PinLayer(
    sourceId: 'businesses',
    layerId: 'businesses-pins',
    placeholderImageId: 'business-pin-placeholder',
    imageIdPrefix: 'business-logo-',
  );

  static const _eventLayer = _PinLayer(
    sourceId: 'map-events',
    layerId: 'map-events-pins',
    placeholderImageId: 'map-event-pin-placeholder',
    imageIdPrefix: 'map-event-cover-',
  );

  /// What an event pin shows before its cover loads, and for the ones that
  /// never had a cover. A car, not a calendar — every category in this app is
  /// something you drive to.
  static const IconData _eventPlaceholderIcon = Icons.directions_car_rounded;

  /// How many images are fetched at once. Enough to fill a screen quickly
  /// without opening 200 sockets on a phone connection.
  static const _imageBatchSize = 8;

  /// Style image ids already registered, so panning back over a pin never
  /// re-downloads its picture. Keyed by the full image id, which encodes the
  /// ring variant — a live event and an upcoming one are different bitmaps.
  final Set<String> _loadedImageIds = {};

  List<BusinessPinEntity> _businesses = const [];
  List<MapEventPinEntity> _events = const [];
  String? _selectedBusinessId;
  String? _selectedEventId;

  /// Centre the pins were fetched around. Collision priority is distance from
  /// here, computed on the client — neither nearby endpoint sends a
  /// `distance_km` to sort by any more.
  GeoPosition? _sortCentre;

  bool _installed = false;
  bool _disposed = false;

  /// Guards against a second image pass starting while one is still running.
  int _imagePass = 0;

  /// Adds both sources, both pin layers and the tap handler. Safe to call again
  /// after a style reload — everything is rebuilt from the cached state.
  ///
  /// [onPinTapped] fires when a pin is hit, [onMapTapped] when the tap lands
  /// anywhere else (which is how an open popup gets dismissed).
  Future<void> installLayers({
    required void Function(MapPinKind kind, String id) onPinTapped,
    required VoidCallback onMapTapped,
  }) async {
    if (_disposed) return;

    await _registerPlaceholders();
    if (_disposed) return;

    // Businesses first so the events layer lands on top of it.
    await _installLayer(_businessLayer);
    await _installLayer(_eventLayer);
    if (_disposed) return;

    // One map-wide tap handler that asks the renderer what was hit, rather
    // than a pin interaction plus a separate dismiss interaction. Several
    // interactions would depend on Mapbox's evaluation order to decide which
    // one wins a tap on a pin; this can't get that wrong.
    _map.addInteraction(
      TapInteraction.onMap((context) async {
        final hit = await _pinAt(context.touchPosition);
        if (_disposed) return;
        if (hit != null) {
          onPinTapped(hit.kind, hit.id);
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
      await setBusinesses(_businesses, selectedId: _selectedBusinessId);
    }
    if (_events.isNotEmpty) {
      await setEvents(_events, selectedId: _selectedEventId);
    }
  }

  /// Replaces the business pins.
  ///
  /// Pins appear immediately with the placeholder marker; logos stream in
  /// afterwards and the source is re-pushed as each batch registers. That way a
  /// slow CDN delays the logos, never the map.
  ///
  /// [centre] is the point the pins were fetched around; it decides which pin
  /// survives a collision. Null leaves the previous centre in place, so a
  /// selection-only refresh doesn't reshuffle the map.
  Future<void> setBusinesses(
    List<BusinessPinEntity> businesses, {
    String? selectedId,
    GeoPosition? centre,
  }) async {
    _businesses = businesses;
    _selectedBusinessId = selectedId;
    _sortCentre = centre ?? _sortCentre;
    if (!_installed || _disposed) return;

    await _pushBusinesses();
    await _loadImages();
  }

  /// Replaces the event pins. Same contract as [setBusinesses].
  Future<void> setEvents(
    List<MapEventPinEntity> events, {
    String? selectedId,
    GeoPosition? centre,
  }) async {
    _events = events;
    _selectedEventId = selectedId;
    _sortCentre = centre ?? _sortCentre;
    if (!_installed || _disposed) return;

    await _pushEvents();
    await _loadImages();
  }

  /// Highlights a pin (or clears the highlight when null) without refetching.
  Future<void> setSelected({String? businessId, String? eventId}) async {
    if (_selectedBusinessId == businessId && _selectedEventId == eventId) {
      return;
    }
    final businessChanged = _selectedBusinessId != businessId;
    final eventChanged = _selectedEventId != eventId;
    _selectedBusinessId = businessId;
    _selectedEventId = eventId;
    if (!_installed || _disposed) return;

    if (businessChanged) await _pushBusinesses();
    if (eventChanged) await _pushEvents();
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

  // ── Install ──────────────────────────────────────────────────────────────

  /// Non-fatal on purpose. These are the first awaits in the install, so an
  /// exception here used to take the sources, the layers and the tap handler
  /// down with it — a marker that won't register should cost us pins, not the
  /// whole map.
  Future<void> _registerPlaceholders() async {
    final placeholders = <String, Future<MbxImage>>{
      _businessLayer.placeholderImageId: _markers.buildPlaceholderMarker(),
      _eventLayer.placeholderImageId:
          _markers.buildPlaceholderMarker(icon: _eventPlaceholderIcon),
    };

    for (final entry in placeholders.entries) {
      try {
        final image = await entry.value;
        if (_disposed) return;
        await _addStyleImage(entry.key, image);
      } catch (e) {
        debugPrint('Failed to register the placeholder marker: $e');
      }
    }
  }

  Future<void> _installLayer(_PinLayer layer) async {
    await _map.style.addSource(
      GeoJsonSource(id: layer.sourceId, data: _emptyCollection),
    );

    await _map.style.addLayer(
      SymbolLayer(
        id: layer.layerId,
        sourceId: layer.sourceId,
        // Per-pin icon: each one points at its own image, falling back to the
        // shared placeholder until that image has been registered.
        iconImageExpression: ['get', 'icon_id'],
        // The selected pin grows slightly so the popup has a visible anchor.
        iconSizeExpression: ['case', ['get', 'selected'], 1.18, 1.0],
        iconAnchor: IconAnchor.CENTER,
        // Left false on purpose: Mapbox then hides colliding pins for us,
        // which is the cheapest possible decluttering in a dense city centre.
        iconAllowOverlap: false,
        iconIgnorePlacement: false,
        // Lower sort key wins a collision — nearest pins survive, and the
        // selected one always does.
        symbolSortKeyExpression: ['get', 'sort_key'],
      ),
    );
  }

  // ── Tap ──────────────────────────────────────────────────────────────────

  /// The pin under [point], or null if the tap missed.
  ///
  /// Queried as a small box rather than a single pixel so a slightly-off tap
  /// still lands. Symbols hidden by collision aren't rendered, so they're
  /// correctly untappable. Events are queried first: they draw on top, so a
  /// tap that hits both belongs to the event.
  Future<({MapPinKind kind, String id})?> _pinAt(ScreenCoordinate point) async {
    const tolerance = 12.0;

    final geometry = RenderedQueryGeometry.fromScreenBox(
      ScreenBox(
        min: ScreenCoordinate(x: point.x - tolerance, y: point.y - tolerance),
        max: ScreenCoordinate(x: point.x + tolerance, y: point.y + tolerance),
      ),
    );

    for (final candidate in [
      (kind: MapPinKind.event, layer: _eventLayer),
      (kind: MapPinKind.business, layer: _businessLayer),
    ]) {
      try {
        final results = await _map.queryRenderedFeatures(
          geometry,
          RenderedQueryOptions(
            layerIds: [candidate.layer.layerId],
            filter: null,
          ),
        );

        for (final result in results) {
          final properties = result?.queriedFeature.feature['properties'];
          if (properties is Map) {
            final id = properties['id'];
            if (id is String) return (kind: candidate.kind, id: id);
          }
        }
      } catch (e) {
        debugPrint('MapLayerController._pinAt failed: $e');
      }
    }
    return null;
  }

  // ── Sources ──────────────────────────────────────────────────────────────

  Future<void> _pushBusinesses() => _pushSource(
        _businessLayer.sourceId,
        [
          for (final b in _businesses)
            _feature(
              id: b.id,
              position: b.position,
              imageId: _imageIdFor(_businessLayer, b.id, b.logoUrl),
              placeholderId: _businessLayer.placeholderImageId,
              isSelected: b.id == _selectedBusinessId,
            ),
        ],
      );

  Future<void> _pushEvents() => _pushSource(
        _eventLayer.sourceId,
        [
          for (final e in _events)
            _feature(
              id: e.id,
              position: e.position,
              imageId: _eventImageId(e),
              placeholderId: _eventLayer.placeholderImageId,
              isSelected: e.id == _selectedEventId,
            ),
        ],
      );

  /// GeoJSON is **longitude-first**. [GeoPosition] exists so this is the only
  /// place the order has to be got right.
  Map<String, dynamic> _feature({
    required String id,
    required GeoPosition position,
    required String? imageId,
    required String placeholderId,
    required bool isSelected,
  }) {
    return {
      'type': 'Feature',
      'id': id,
      'geometry': {
        'type': 'Point',
        'coordinates': [position.lng, position.lat],
      },
      'properties': {
        'id': id,
        'icon_id': (imageId != null && _loadedImageIds.contains(imageId))
            ? imageId
            : placeholderId,
        'selected': isSelected,
        // Lower wins a collision: the open popup's pin always survives, then
        // the pins nearest the fetch centre. With no centre yet every pin ties
        // and Mapbox falls back to source order.
        'sort_key': isSelected
            ? -1.0
            : (_sortCentre?.distanceKmTo(position) ?? 0.0),
      },
    };
  }

  Future<void> _pushSource(
    String sourceId,
    List<Map<String, dynamic>> features,
  ) async {
    try {
      final source = await _map.style.getSource(sourceId);
      if (source is GeoJsonSource) {
        await source.updateGeoJSON(
          jsonEncode({'type': 'FeatureCollection', 'features': features}),
        );
      }
    } catch (e) {
      debugPrint('MapLayerController._pushSource($sourceId) failed: $e');
    }
  }

  // ── Images ───────────────────────────────────────────────────────────────

  /// Fetches and registers every pin image that isn't cached yet, in batches,
  /// re-pushing the affected source after each one so pins swap from the
  /// placeholder to their own picture as they arrive.
  Future<void> _loadImages() async {
    final pending = <_PendingImage>[
      for (final b in _businesses)
        if (_imageIdFor(_businessLayer, b.id, b.logoUrl) case final id?)
          if (!_loadedImageIds.contains(id))
            _PendingImage(
              imageId: id,
              url: b.logoUrl,
              ring: AppColors.surface,
              isEvent: false,
            ),
      for (final e in _events)
        if (_eventImageId(e) case final id?)
          if (!_loadedImageIds.contains(id))
            _PendingImage(
              imageId: id,
              url: e.coverImageUrl!,
              // A live meet wears an accent ring so it reads as "happening
              // now" without opening anything.
              ring: e.isLive ? AppColors.accent : AppColors.surface,
              isEvent: true,
            ),
    ];
    if (pending.isEmpty) return;

    final pass = ++_imagePass;

    for (var i = 0; i < pending.length; i += _imageBatchSize) {
      if (_disposed || pass != _imagePass) return;

      final batch = pending.skip(i).take(_imageBatchSize).toList();
      final images = await Future.wait(
        batch.map((p) => _markers.buildImageMarker(p.url, ring: p.ring)),
      );
      if (_disposed || pass != _imagePass) return;

      var businessesChanged = false;
      var eventsChanged = false;
      for (var j = 0; j < batch.length; j++) {
        final image = images[j];
        if (image == null) continue;
        try {
          await _addStyleImage(batch[j].imageId, image);
          _loadedImageIds.add(batch[j].imageId);
          if (batch[j].isEvent) {
            eventsChanged = true;
          } else {
            businessesChanged = true;
          }
        } catch (e) {
          debugPrint('Failed to register image ${batch[j].imageId}: $e');
        }
      }

      if (_disposed || pass != _imagePass) return;
      // Only re-push once per batch, and only the sources that changed.
      if (businessesChanged) await _pushBusinesses();
      if (eventsChanged) await _pushEvents();
    }
  }

  Future<void> _addStyleImage(String id, MbxImage image) {
    return _map.style.addStyleImage(
      id,
      MapMarkerFactory.scale,
      image,
      false,
      [],
      [],
      null,
    );
  }

  /// Null when there's no image to fetch, which keeps that pin on the shared
  /// placeholder forever instead of retrying a URL that doesn't exist.
  static String? _imageIdFor(_PinLayer layer, String id, String? url) {
    if (url == null || url.isEmpty) return null;
    return '${layer.imageIdPrefix}$id';
  }

  /// The ring colour is baked into the bitmap, so it has to be part of the id —
  /// otherwise an event that goes live keeps the white-ringed image it was
  /// first registered with.
  static String? _eventImageId(MapEventPinEntity event) {
    final base = _imageIdFor(_eventLayer, event.id, event.coverImageUrl);
    if (base == null) return null;
    return event.isLive ? '$base-live' : base;
  }

  static const _emptyCollection = '{"type":"FeatureCollection","features":[]}';

  void dispose() {
    _disposed = true;
    _markers.dispose();
  }
}

/// The static identity of one pin layer: its source, its layer, and how its
/// style-image ids are named.
class _PinLayer {
  final String sourceId;
  final String layerId;
  final String placeholderImageId;
  final String imageIdPrefix;

  const _PinLayer({
    required this.sourceId,
    required this.layerId,
    required this.placeholderImageId,
    required this.imageIdPrefix,
  });
}

class _PendingImage {
  final String imageId;
  final String url;
  final Color ring;
  final bool isEvent;

  const _PendingImage({
    required this.imageId,
    required this.url,
    required this.ring,
    required this.isEvent,
  });
}
