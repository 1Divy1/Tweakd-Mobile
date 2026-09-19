import 'package:tweakd/features/map_events/domain/entities/map_event_pin.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/business_detail_entity.dart';
import '../../../domain/entities/business_pin_entity.dart';
import '../../../domain/entities/geo_position.dart';
import '../../utils/map_error_mapper.dart';

/// Lifecycle of the pin data. Unlike the app's list pages the map never swaps
/// itself out for a full-screen error view — a failed fetch keeps whatever pins
/// are already on the map and raises a dismissible banner instead.
enum MapStatus { initial, loading, loaded, failure }

/// Lifecycle of the tapped business's profile, which drives the popup.
enum BusinessDetailStatus { idle, loading, loaded, failure }

/// A one-shot "fly the camera here" request.
///
/// The map is an imperative controller, so this can't be expressed as plain
/// state — [seq] increments on every request so a `BlocListener` can tell a
/// fresh command from a rebuild carrying the same target.
class MapCameraCommand extends Equatable {
  final GeoPosition target;
  final int seq;

  /// Null keeps the map's default overview zoom; a search result asks to land
  /// closer in, on the one thing the user was looking for.
  final double? zoom;

  const MapCameraCommand({required this.target, required this.seq, this.zoom});

  @override
  List<Object?> get props => [target, seq, zoom];
}

class MapState extends Equatable {
  final MapStatus status;

  /// Centre of the most recent successful fetch. Null until the first one
  /// lands; used to decide whether a settled camera is worth refetching for.
  final GeoPosition? fetchCentre;

  /// False when [fetchCentre] came from [kMapFallbackCentre] rather than a real
  /// device fix — the recentre button uses this to know it has work to do.
  final bool hasDeviceLocation;

  final List<BusinessPinEntity> businesses;

  /// Event pins around [fetchCentre]. Fetched alongside the businesses on the
  /// same camera-settled trigger, and failing independently of them — one layer
  /// being down shouldn't empty the other.
  final List<MapEventPinEntity> events;

  /// Banner over the map. Never replaces the map itself.
  final MapErrorCode? errorCode;

  final MapCameraCommand? cameraCommand;

  final String? selectedBusinessId;
  final BusinessDetailStatus detailStatus;
  final BusinessDetailEntity? selectedBusiness;
  final MapErrorCode? detailErrorCode;

  /// The tapped event pin. Mutually exclusive with [selectedBusinessId] — one
  /// popup at a time — and the event's own detail lives in
  /// `MapEventDetailBloc`, not here, because the detail *page* needs exactly
  /// the same state and actions.
  final String? selectedEventId;

  /// The business picked on the search screen, drawn even if the nearby fetch
  /// hasn't (or never will) include it. Lives exactly as long as the selection
  /// it came with — dismissing the popup, or tapping another pin, drops it.
  final BusinessPinEntity? searchBusiness;

  /// The event picked on the search screen. Same lifetime as [searchBusiness];
  /// for a past event this is the *only* way it gets a pin, since the nearby
  /// query only returns upcoming and live ones.
  final MapEventPinEntity? searchEvent;

  const MapState({
    this.status = MapStatus.initial,
    this.fetchCentre,
    this.hasDeviceLocation = false,
    this.businesses = const [],
    this.events = const [],
    this.errorCode,
    this.cameraCommand,
    this.selectedBusinessId,
    this.detailStatus = BusinessDetailStatus.idle,
    this.selectedBusiness,
    this.detailErrorCode,
    this.selectedEventId,
    this.searchBusiness,
    this.searchEvent,
  });

  bool get isPopupOpen => selectedBusinessId != null || selectedEventId != null;

  /// What the businesses layer draws: the nearby pins plus the searched-for
  /// one, unless the nearby fetch already brought it in.
  List<BusinessPinEntity> get visibleBusinesses {
    final extra = searchBusiness;
    if (extra == null || businesses.any((b) => b.id == extra.id)) {
      return businesses;
    }
    return [...businesses, extra];
  }

  /// What the events layer draws: the nearby pins plus the searched-for one,
  /// unless the nearby fetch already brought it in.
  List<MapEventPinEntity> get visibleEvents {
    final extra = searchEvent;
    if (extra == null || events.any((e) => e.id == extra.id)) return events;
    return [...events, extra];
  }

  /// The tapped event, straight from the already-loaded pins, so the popup can
  /// show a cover, a title and the counts while `GET /map-events/{id}` is
  /// still in flight.
  MapEventPinEntity? get selectedEventPin {
    final id = selectedEventId;
    if (id == null) return null;
    for (final e in visibleEvents) {
      if (e.id == id) return e;
    }
    return null;
  }

  /// The tapped pin, available immediately from the already-loaded list so the
  /// popup can show a name and logo while the full profile is still in flight.
  BusinessPinEntity? get selectedPin {
    final id = selectedBusinessId;
    if (id == null) return null;
    for (final b in visibleBusinesses) {
      if (b.id == id) return b;
    }
    return null;
  }

  MapState copyWith({
    MapStatus? status,
    GeoPosition? fetchCentre,
    bool? hasDeviceLocation,
    List<BusinessPinEntity>? businesses,
    List<MapEventPinEntity>? events,
    MapErrorCode? errorCode,
    bool clearError = false,
    MapCameraCommand? cameraCommand,
    String? selectedBusinessId,
    BusinessDetailStatus? detailStatus,
    BusinessDetailEntity? selectedBusiness,
    MapErrorCode? detailErrorCode,
    String? selectedEventId,
    BusinessPinEntity? searchBusiness,
    MapEventPinEntity? searchEvent,
    bool clearSelection = false,
    bool clearDetail = false,
  }) {
    final dropDetail = clearSelection || clearDetail;
    return MapState(
      status: status ?? this.status,
      fetchCentre: fetchCentre ?? this.fetchCentre,
      hasDeviceLocation: hasDeviceLocation ?? this.hasDeviceLocation,
      businesses: businesses ?? this.businesses,
      events: events ?? this.events,
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      cameraCommand: cameraCommand ?? this.cameraCommand,
      selectedBusinessId:
          clearSelection ? null : (selectedBusinessId ?? this.selectedBusinessId),
      detailStatus: clearSelection
          ? BusinessDetailStatus.idle
          : (detailStatus ?? this.detailStatus),
      selectedBusiness:
          dropDetail ? selectedBusiness : (selectedBusiness ?? this.selectedBusiness),
      detailErrorCode:
          dropDetail ? detailErrorCode : (detailErrorCode ?? this.detailErrorCode),
      selectedEventId:
          clearSelection ? null : (selectedEventId ?? this.selectedEventId),
      searchBusiness:
          clearSelection ? null : (searchBusiness ?? this.searchBusiness),
      searchEvent: clearSelection ? null : (searchEvent ?? this.searchEvent),
    );
  }

  @override
  List<Object?> get props => [
        status,
        fetchCentre,
        hasDeviceLocation,
        businesses,
        events,
        errorCode,
        cameraCommand,
        selectedBusinessId,
        detailStatus,
        selectedBusiness,
        detailErrorCode,
        selectedEventId,
        searchBusiness,
        searchEvent,
      ];
}
