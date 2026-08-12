import 'package:equatable/equatable.dart';

import '../../../domain/entities/geo_position.dart';

sealed class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

/// Fired once when the page mounts: resolve the user's position (falling back
/// to the default centre when it's unavailable) and load the first ring of
/// businesses around it.
class MapStarted extends MapEvent {
  const MapStarted();
}

/// The camera stopped moving. The bloc decides whether the new centre is far
/// enough from the last fetch to be worth another request — `onMapIdle` fires
/// after every pan, and most pans don't warrant one.
class MapCameraSettled extends MapEvent {
  final GeoPosition centre;

  const MapCameraSettled(this.centre);

  @override
  List<Object?> get props => [centre];
}

/// An event pin was tapped: open the event preview popup. Loading the event
/// itself is `MapEventDetailBloc`'s job — the popup and the detail page share
/// it — so this only moves the selection.
class MapEventPinSelected extends MapEvent {
  final String eventId;

  const MapEventPinSelected(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

/// A pin was tapped: open the popup and fetch that business's full profile.
class MapBusinessSelected extends MapEvent {
  final String businessId;

  const MapBusinessSelected(this.businessId);

  @override
  List<Object?> get props => [businessId];
}

/// Whichever popup is open was dismissed (tap outside, close button, back).
class MapBusinessDismissed extends MapEvent {
  const MapBusinessDismissed();
}

/// The map's own copy of an event pin is stale — its counts changed because the
/// viewer just RSVP'd or registered a car from the popup. Patches the pin in
/// place rather than refetching the whole ring.
class MapEventPinRefreshed extends MapEvent {
  final String eventId;
  final int attendeesCount;
  final int attendingCarsCount;

  const MapEventPinRefreshed({
    required this.eventId,
    required this.attendeesCount,
    required this.attendingCarsCount,
  });

  @override
  List<Object?> get props => [eventId, attendeesCount, attendingCarsCount];
}

/// Retry after a failed business fetch, from the popup's error state.
class MapBusinessDetailRetried extends MapEvent {
  const MapBusinessDetailRetried();
}

/// The "recentre on me" button. Re-asks for a fix and reloads around it.
class MapRecentreRequested extends MapEvent {
  const MapRecentreRequested();
}

/// Dismiss the error banner floating over the map.
class MapErrorDismissed extends MapEvent {
  const MapErrorDismissed();
}
