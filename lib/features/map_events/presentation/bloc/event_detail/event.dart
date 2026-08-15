import 'package:equatable/equatable.dart';

import '../../../domain/entities/map_event_enums.dart';

sealed class MapEventDetailEvent extends Equatable {
  const MapEventDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Open an event: fetch it, the first few attendees for the avatar stack, and
/// the first page of the entry list.
///
/// Re-dispatching with the same id is a no-op unless [force] is set, so the map
/// popup can fire it on every selection change without refetching when the user
/// closes and reopens the same card.
class LoadMapEvent extends MapEventDetailEvent {
  final String eventId;
  final bool force;

  const LoadMapEvent(this.eventId, {this.force = false});

  @override
  List<Object?> get props => [eventId, force];
}

/// Pull-to-refresh, and the way the detail page recovers after a write that
/// doesn't return the event.
class RefreshMapEvent extends MapEventDetailEvent {
  const RefreshMapEvent();
}

/// Tap on Attending / Interested. Tapping the status that's already active
/// clears the RSVP instead of re-sending it.
class ToggleMapEventRsvp extends MapEventDetailEvent {
  final MapEventAttendance status;

  const ToggleMapEventRsvp(this.status);

  @override
  List<Object?> get props => [status];
}

/// Put one or more of the viewer's garage cars on the entry list. Submitted
/// all-or-nothing: if any car in the batch is refused (deadline, capacity),
/// whichever already landed is rolled back rather than left half-registered.
class RegisterCarsForEvent extends MapEventDetailEvent {
  final List<String> carIds;

  const RegisterCarsForEvent(this.carIds);

  @override
  List<Object?> get props => [carIds];
}

/// Take back a registration the organizers haven't accepted yet. Accepted
/// entries need [SubmitEventWithdrawal] instead.
class CancelPendingCarRegistration extends MapEventDetailEvent {
  final String carId;

  const CancelPendingCarRegistration(this.carId);

  @override
  List<Object?> get props => [carId];
}

/// Ask the organizers to be let out. One-way — there is no matching "undo".
class SubmitEventWithdrawal extends MapEventDetailEvent {
  final String? note;

  const SubmitEventWithdrawal(this.note);

  @override
  List<Object?> get props => [note];
}

/// Next page of the Cars tab.
class LoadMoreEventCars extends MapEventDetailEvent {
  const LoadMoreEventCars();
}

/// Dismiss the one-shot action error (a snackbar has shown it).
class ClearMapEventActionError extends MapEventDetailEvent {
  const ClearMapEventActionError();
}
