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

  /// The viewer's own cars in this event, whatever their status, straight from
  /// `GET /{id}/cars/mine` — pending, accepted, rejected and withdrawn rows
  /// alike, with the organizer's reason on the rejected ones.
  final List<MapEventParticipantEntity> myParticipations;

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

  /// How many of the viewer's cars a withdrawal would take out. `POST
  /// /withdraw` has no per-car variant — it flags every live entry the caller
  /// has — so the confirmation dialog names this number rather than implying
  /// one car is at stake.
  int get withdrawableCarCount {
    var count = 0;
    for (final p in myParticipations) {
      if (p.isAccepted || p.isPending) count++;
    }
    return count;
  }

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
        action,
        actionError,
      ];
}
