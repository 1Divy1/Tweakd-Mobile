import 'package:equatable/equatable.dart';
import 'package:tweakd/features/map_events/domain/entities/map_event_enums.dart';
import 'package:tweakd/features/map_events/domain/entities/map_event_pin.dart';

import '../../../domain/entities/business_pin_entity.dart';
import '../../../domain/entities/geo_position.dart';
import '../../utils/map_error_mapper.dart';

/// The two result tabs. Each pages independently.
enum MapSearchKind { events, businesses }

enum MapSearchSectionStatus { idle, loading, loaded, failure }

/// The phases the Events tab shows until the viewer changes the chips: what
/// they can still act on. Past events are for looking back, so they're opt-in.
const kDefaultMapSearchStatuses = {MapEventStatus.live, MapEventStatus.upcoming};

/// One tab's results: a keyset-paged list plus where it is in its lifecycle.
///
/// [status] is about the *first* page — it decides between the spinner, the
/// error view and the list. A later page failing keeps the list on screen and
/// only sets [loadMoreFailed], which turns the footer into a retry row.
class MapSearchSection<T> extends Equatable {
  final MapSearchSectionStatus status;
  final List<T> items;
  final String? nextCursor;
  final bool isLoadingMore;
  final bool loadMoreFailed;
  final MapErrorCode? errorCode;

  const MapSearchSection({
    this.status = MapSearchSectionStatus.idle,
    this.items = const [],
    this.nextCursor,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
    this.errorCode,
  });

  const MapSearchSection.loading() : this(status: MapSearchSectionStatus.loading);

  bool get hasMore => nextCursor != null;

  MapSearchSection<T> copyWith({
    MapSearchSectionStatus? status,
    List<T>? items,
    String? nextCursor,
    bool clearCursor = false,
    bool? isLoadingMore,
    bool? loadMoreFailed,
    MapErrorCode? errorCode,
  }) {
    return MapSearchSection<T>(
      status: status ?? this.status,
      items: items ?? this.items,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
      errorCode: errorCode ?? this.errorCode,
    );
  }

  @override
  List<Object?> get props =>
      [status, items, nextCursor, isLoadingMore, loadMoreFailed, errorCode];
}

class MapSearchState extends Equatable {
  /// Where the map was looking when search opened. Results are ordered
  /// nearest to it, and every page of one search must send the same centre.
  final GeoPosition centre;

  /// The settled (debounced, trimmed) query the sections belong to. Empty
  /// while the field holds fewer than two characters.
  final String query;

  final Set<MapEventStatus> statuses;
  final MapSearchSection<MapEventPinEntity> events;
  final MapSearchSection<BusinessPinEntity> businesses;

  const MapSearchState({
    required this.centre,
    this.query = '',
    this.statuses = kDefaultMapSearchStatuses,
    this.events = const MapSearchSection(),
    this.businesses = const MapSearchSection(),
  });

  bool get hasQuery => query.isNotEmpty;

  MapSearchState copyWith({
    String? query,
    Set<MapEventStatus>? statuses,
    MapSearchSection<MapEventPinEntity>? events,
    MapSearchSection<BusinessPinEntity>? businesses,
  }) {
    return MapSearchState(
      centre: centre,
      query: query ?? this.query,
      statuses: statuses ?? this.statuses,
      events: events ?? this.events,
      businesses: businesses ?? this.businesses,
    );
  }

  @override
  List<Object?> get props => [centre, query, statuses, events, businesses];
}
