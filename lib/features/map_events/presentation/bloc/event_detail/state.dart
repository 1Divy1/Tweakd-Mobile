import 'package:equatable/equatable.dart';

import '../../../domain/entities/map_event.dart';
import '../../../domain/entities/map_event_attendee.dart';
import '../../../domain/entities/map_event_participant.dart';
import '../../utils/map_event_error_mapper.dart';

enum MapEventDetailStatus { initial, loading, loaded, failure }

/// Which action is currently in flight, so exactly one spinner shows and the
/// buttons that would conflict with it go inert.
enum MapEventAction { none, rsvp, register, cancelRegistration, withdraw }

/// State behind **both** the map's event popup and the full detail page.
///
/// They render very differently but need identical data and identical actions,
/// so sharing one bloc is what keeps RSVP, registration and withdrawal logic
/// from existing twice.
class MapEventDetailState extends Equatable {
  final MapEventDetailStatus status;
  final String? eventId;
  final MapEventEntity? event;
  final MapEventError? error;

  /// First handful of attendees, for the "N going" avatar stack.
  final List<MapEventAttendeeEntity> attendeePreview;

  /// The public entry list — `?status=accepted` only, which is what the design
  /// counts as "N APPROVED". The unfiltered endpoint would fold in withdrawn
  /// rows.
  final List<MapEventParticipantEntity> cars;
  final String? carsNextCursor;
  final bool isLoadingCars;
  final bool isLoadingMoreCars;

  /// The viewer's own cars in this event, with the statuses that could actually
  /// be resolved.
  ///
  /// `viewer.my_registered_car_ids` has no per-car status, so these are
  /// cross-referenced against the car list. Accepted and withdrawn rows are
  /// public and always resolvable; **pending and rejected rows are
  /// organizer-only**, so a plain participant's own pending request is
  /// invisible until they make it in this session (see
  /// [unresolvedRegisteredCarIds] and `MAP_EVENTS_NOTES.md` §1.2).
  final List<MapEventParticipantEntity> myParticipations;

  /// Registered car ids whose status the backend wouldn't reveal to this
  /// viewer. The UI treats them as "something is in progress" rather than
  /// claiming a status it doesn't know.
  final List<String> unresolvedRegisteredCarIds;

  final MapEventAction action;

  /// One-shot: shown in a snackbar, then cleared.
  final MapEventError? actionError;

  const MapEventDetailState({
    this.status = MapEventDetailStatus.initial,
    this.eventId,
    this.event,
    this.error,
    this.attendeePreview = const [],
    this.cars = const [],
    this.carsNextCursor,
    this.isLoadingCars = false,
    this.isLoadingMoreCars = false,
    this.myParticipations = const [],
    this.unresolvedRegisteredCarIds = const [],
    this.action = MapEventAction.none,
    this.actionError,
  });

  bool get hasMoreCars => carsNextCursor != null;
  bool get isBusy => action != MapEventAction.none;

  /// The viewer's accepted entry, if any — what turns the participation button
  /// into "✓ Participating" and unlocks Withdraw.
  MapEventParticipantEntity? get myAcceptedEntry {
    for (final p in myParticipations) {
      if (p.isAccepted) return p;
    }
    return null;
  }

  MapEventParticipantEntity? get myPendingEntry {
    for (final p in myParticipations) {
      if (p.isPending) return p;
    }
    return null;
  }

  MapEventParticipantEntity? get myWithdrawnEntry {
    for (final p in myParticipations) {
      if (p.isWithdrawn) return p;
    }
    return null;
  }

  MapEventParticipantEntity? get myRejectedEntry {
    for (final p in myParticipations) {
      if (p.isRejected) return p;
    }
    return null;
  }

  /// True when the viewer has *something* registered whose state we couldn't
  /// read — a pending request made on another device, typically.
  bool get hasUnresolvedRegistration => unresolvedRegisteredCarIds.isNotEmpty;

  MapEventDetailState copyWith({
    MapEventDetailStatus? status,
    String? eventId,
    MapEventEntity? event,
    MapEventError? error,
    bool clearError = false,
    List<MapEventAttendeeEntity>? attendeePreview,
    List<MapEventParticipantEntity>? cars,
    String? carsNextCursor,
    bool clearCarsCursor = false,
    bool? isLoadingCars,
    bool? isLoadingMoreCars,
    List<MapEventParticipantEntity>? myParticipations,
    List<String>? unresolvedRegisteredCarIds,
    MapEventAction? action,
    MapEventError? actionError,
    bool clearActionError = false,
  }) {
    return MapEventDetailState(
      status: status ?? this.status,
      eventId: eventId ?? this.eventId,
      event: event ?? this.event,
      error: clearError ? null : (error ?? this.error),
      attendeePreview: attendeePreview ?? this.attendeePreview,
      cars: cars ?? this.cars,
      carsNextCursor:
          clearCarsCursor ? null : (carsNextCursor ?? this.carsNextCursor),
      isLoadingCars: isLoadingCars ?? this.isLoadingCars,
      isLoadingMoreCars: isLoadingMoreCars ?? this.isLoadingMoreCars,
      myParticipations: myParticipations ?? this.myParticipations,
      unresolvedRegisteredCarIds:
          unresolvedRegisteredCarIds ?? this.unresolvedRegisteredCarIds,
      action: action ?? this.action,
      actionError:
          clearActionError ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props => [
        status,
        eventId,
        event,
        error,
        attendeePreview,
        cars,
        carsNextCursor,
        isLoadingCars,
        isLoadingMoreCars,
        myParticipations,
        unresolvedRegisteredCarIds,
        action,
        actionError,
      ];
}
