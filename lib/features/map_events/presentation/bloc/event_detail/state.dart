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

  /// One row per car, keeping only the most recent (`registeredAt`) among the
  /// caller's rows for that car.
  ///
  /// The backend never deletes a superseded row — a car that was rejected and
  /// then re-registered leaves its old "rejected" row sitting in `/cars/mine`
  /// right alongside the new one. Without this, the declined strip kept
  /// quoting that stale row forever, even after the resend was accepted.
  List<MapEventParticipantEntity> get _effectiveParticipations {
    final byCar = <String, MapEventParticipantEntity>{};
    for (final p in myParticipations) {
      final existing = byCar[p.car.id];
      if (existing == null || p.registeredAt.isAfter(existing.registeredAt)) {
        byCar[p.car.id] = p;
      }
    }
    return byCar.values.toList();
  }

  /// The viewer's accepted entries — what turns the participation button into
  /// "✓ Participating" and unlocks Withdraw. Can hold more than one car.
  List<MapEventParticipantEntity> get myAcceptedEntries =>
      _effectiveParticipations.where((p) => p.isAccepted).toList();

  List<MapEventParticipantEntity> get myPendingEntries =>
      _effectiveParticipations.where((p) => p.isPending).toList();

  List<MapEventParticipantEntity> get myWithdrawnEntries =>
      _effectiveParticipations.where((p) => p.isWithdrawn).toList();

  List<MapEventParticipantEntity> get myRejectedEntries =>
      _effectiveParticipations.where((p) => p.isRejected).toList();

  MapEventParticipantEntity? get myAcceptedEntry =>
      myAcceptedEntries.isEmpty ? null : myAcceptedEntries.first;

  MapEventParticipantEntity? get myPendingEntry =>
      myPendingEntries.isEmpty ? null : myPendingEntries.first;

  MapEventParticipantEntity? get myWithdrawnEntry =>
      myWithdrawnEntries.isEmpty ? null : myWithdrawnEntries.first;

  MapEventParticipantEntity? get myRejectedEntry =>
      myRejectedEntries.isEmpty ? null : myRejectedEntries.first;

  /// Whether the viewer has any live relationship to the car-entry side of the
  /// event — accepted, awaiting approval, or awaiting a withdrawal to go
  /// through. Participating outranks a plain RSVP, so this is what tells the
  /// Attending/Interested row to step aside rather than show alongside it.
  bool get hasActiveParticipation =>
      myAcceptedEntries.isNotEmpty ||
      myPendingEntry != null ||
      myWithdrawnEntry != null;

  /// Cars the viewer already has a live (pending or accepted) row for in this
  /// event — excluded from the picker so registering "again" can't create a
  /// duplicate row for the same car. A rejected or withdrawn car is *not*
  /// excluded: resubmitting it is exactly how "try another car" works.
  Set<String> get activeParticipationCarIds => {
        for (final p in myAcceptedEntries) p.car.id,
        for (final p in myPendingEntries) p.car.id,
      };

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
