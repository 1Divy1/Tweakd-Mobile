import 'package:equatable/equatable.dart';
import 'package:tweakd/features/map_events/domain/entities/map_event_enums.dart';

import 'state.dart';

sealed class MapSearchEvent extends Equatable {
  const MapSearchEvent();

  @override
  List<Object?> get props => [];
}

/// The text field changed. Debounced inside the bloc: only a query that stays
/// put for a moment reaches the backend.
class MapSearchQueryChanged extends MapSearchEvent {
  final String query;

  const MapSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// The clear (×) button: back to the empty state, nothing in flight.
class MapSearchCleared extends MapSearchEvent {
  const MapSearchCleared();
}

/// A phase chip on the Events tab was tapped. Turning off the last chip still
/// on is ignored — "no phases" would be a list that can never have anything
/// in it.
class MapSearchStatusToggled extends MapSearchEvent {
  final MapEventStatus status;

  const MapSearchStatusToggled(this.status);

  @override
  List<Object?> get props => [status];
}

/// The list scrolled near its end: fetch the next page of [kind].
class MapSearchMoreRequested extends MapSearchEvent {
  final MapSearchKind kind;

  const MapSearchMoreRequested(this.kind);

  @override
  List<Object?> get props => [kind];
}

/// Retry after a failed page of [kind] — the first page or a later one.
class MapSearchRetried extends MapSearchEvent {
  final MapSearchKind kind;

  const MapSearchRetried(this.kind);

  @override
  List<Object?> get props => [kind];
}

/// Internal: the debounce elapsed on [query].
class MapSearchSubmitted extends MapSearchEvent {
  final String query;

  const MapSearchSubmitted(this.query);

  @override
  List<Object?> get props => [query];
}
