import 'package:car_social_media_app/core/error/base_failures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/map_event.dart';
import '../../../domain/entities/map_event_enums.dart';
import '../../../domain/entities/map_event_participant.dart';
import '../../../domain/usecases/map_event_attendance.dart';
import '../../../domain/usecases/map_event_participation.dart';
import '../../../domain/usecases/map_event_reads.dart';
import '../../../domain/usecases/map_event_withdrawals.dart';
import '../../utils/map_event_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// One bloc behind the map's event popup **and** the full event page.
///
/// They look nothing alike but need the same three things — the event, who's
/// going, and what the viewer may do about it — so the RSVP / register /
/// withdraw logic lives here once instead of being written twice and drifting.
///
/// Two contract quirks shape most of this file:
///
/// * **Writes return the event, except the participation ones.** `PUT/DELETE
///   attendance` answer with a fresh `MapEventDto`, so an RSVP needs no
///   refetch. `POST /cars`, `DELETE /cars/{id}` and `POST /withdraw` answer
///   with participant rows (or nothing), so those *do* refetch to pick up the
///   new counts and viewer flags.
/// * **The viewer object has no per-car status.** Working out whether the
///   viewer's car is accepted, withdrawn or still pending means matching
///   `my_registered_car_ids` against the car list — and the pending/rejected
///   slices of that list are organizer-only, so a participant's own pending
///   request is unreadable on a cold open. Anything that can't be resolved is
///   kept in `unresolvedRegisteredCarIds` rather than guessed at.
@injectable
class MapEventDetailBloc
    extends Bloc<MapEventDetailEvent, MapEventDetailState> {
  final GetMapEventUseCase getEvent;
  final GetMapEventAttendeesUseCase getAttendees;
  final GetMapEventCarsUseCase getCars;
  final SetMapEventAttendanceUseCase setAttendance;
  final ClearMapEventAttendanceUseCase clearAttendance;
  final RegisterCarForMapEventUseCase registerCar;
  final CancelCarRegistrationUseCase cancelCarRegistration;
  final WithdrawFromMapEventUseCase withdraw;

  /// How many avatars the "N going" stack shows before the "+N" overflow.
  static const _attendeePreviewSize = 8;

  static const _carsPageSize = 20;

  MapEventDetailBloc({
    required this.getEvent,
    required this.getAttendees,
    required this.getCars,
    required this.setAttendance,
    required this.clearAttendance,
    required this.registerCar,
    required this.cancelCarRegistration,
    required this.withdraw,
  }) : super(const MapEventDetailState()) {
    on<LoadMapEvent>(_onLoad);
    on<RefreshMapEvent>(_onRefresh);
    on<ToggleMapEventRsvp>(_onToggleRsvp);
    on<RegisterCarForEvent>(_onRegisterCar);
    on<CancelPendingCarRegistration>(_onCancelRegistration);
    on<SubmitEventWithdrawal>(_onWithdraw);
    on<LoadMoreEventCars>(_onLoadMoreCars);
    on<ClearMapEventActionError>(_onClearActionError);
  }

  // ── Loading ──────────────────────────────────────────────────────────────

  Future<void> _onLoad(
    LoadMapEvent event,
    Emitter<MapEventDetailState> emit,
  ) async {
    // Reopening the same popup shouldn't cost a round trip.
    if (!event.force &&
        state.eventId == event.eventId &&
        state.status == MapEventDetailStatus.loaded) {
      return;
    }

    emit(MapEventDetailState(
      status: MapEventDetailStatus.loading,
      eventId: event.eventId,
      isLoadingCars: true,
    ));

    await _load(event.eventId, emit);
  }

  Future<void> _onRefresh(
    RefreshMapEvent event,
    Emitter<MapEventDetailState> emit,
  ) async {
    final id = state.eventId;
    if (id == null) return;
    await _load(id, emit, keepPreviousOnFailure: true);
  }

  /// Fetches the event, its attendee preview and the first page of the entry
  /// list. The three requests overlap; only the event's failure is fatal — a
  /// missing avatar row is not worth an error screen.
  Future<void> _load(
    String eventId,
    Emitter<MapEventDetailState> emit, {
    bool keepPreviousOnFailure = false,
  }) async {
    final eventRequest = getEvent(GetMapEventParams(eventId: eventId));
    final attendeesRequest = getAttendees(
      GetMapEventAttendeesParams(
        eventId: eventId,
        status: MapEventAttendance.attending,
        size: _attendeePreviewSize,
      ),
    );
    final carsRequest = getCars(
      GetMapEventCarsParams(
        eventId: eventId,
        status: MapEventParticipation.accepted,
        size: _carsPageSize,
      ),
    );

    final eventResult = await eventRequest;
    final attendeesResult = await attendeesRequest;
    final carsResult = await carsRequest;

    // A response for an event the user has already navigated away from.
    if (state.eventId != eventId) return;

    final loaded = eventResult.toOption().toNullable();
    if (loaded == null) {
      final error = MapEventErrorMapper.from(
        eventResult.fold((f) => f, (_) => const UnknownFailure('')),
      );
      // A failed *refresh* keeps the page it already has and says so in a
      // snackbar; only a failed first load takes over the screen.
      emit(
        keepPreviousOnFailure && state.event != null
            ? state.copyWith(isLoadingCars: false, actionError: error)
            : state.copyWith(
                status: MapEventDetailStatus.failure,
                isLoadingCars: false,
                error: error,
              ),
      );
      return;
    }

    final carsPage = carsResult.toOption().toNullable();
    final cars = carsPage?.items ?? const <MapEventParticipantEntity>[];

    final resolved = await _resolveMyParticipations(loaded, cars);
    if (state.eventId != eventId) return;

    emit(state.copyWith(
      status: MapEventDetailStatus.loaded,
      event: loaded,
      clearError: true,
      attendeePreview:
          attendeesResult.toOption().toNullable()?.items ?? const [],
      cars: cars,
      carsNextCursor: carsPage?.nextCursor,
      clearCarsCursor: carsPage?.nextCursor == null,
      isLoadingCars: false,
      myParticipations: resolved.participations,
      unresolvedRegisteredCarIds: resolved.unresolvedIds,
      action: MapEventAction.none,
    ));
  }

  Future<void> _onLoadMoreCars(
    LoadMoreEventCars event,
    Emitter<MapEventDetailState> emit,
  ) async {
    final id = state.eventId;
    final cursor = state.carsNextCursor;
    if (id == null || cursor == null || state.isLoadingMoreCars) return;

    emit(state.copyWith(isLoadingMoreCars: true));

    final result = await getCars(
      GetMapEventCarsParams(
        eventId: id,
        status: MapEventParticipation.accepted,
        cursor: cursor,
        size: _carsPageSize,
      ),
    );

    if (state.eventId != id) return;

    result.fold(
      // A failed "load more" shouldn't blow away what's already on screen.
      (_) => emit(state.copyWith(isLoadingMoreCars: false)),
      (page) => emit(state.copyWith(
        cars: [...state.cars, ...page.items],
        carsNextCursor: page.nextCursor,
        clearCarsCursor: page.nextCursor == null,
        isLoadingMoreCars: false,
      )),
    );
  }

  // ── RSVP ─────────────────────────────────────────────────────────────────

  /// Optimistic: the button flips on tap and the server's own event overwrites
  /// it a moment later. Tapping the active status clears the RSVP — that's what
  /// makes the pair behave like a toggle rather than a one-way switch.
  Future<void> _onToggleRsvp(
    ToggleMapEventRsvp event,
    Emitter<MapEventDetailState> emit,
  ) async {
    final current = state.event;
    if (current == null || state.isBusy) return;
    if (!current.viewer.canRsvp) return;

    final wasActive = current.viewer.attendanceStatus == event.status;
    final optimistic = _optimisticRsvp(current, wasActive ? null : event.status);

    emit(state.copyWith(
      event: optimistic,
      action: MapEventAction.rsvp,
      clearActionError: true,
    ));

    final result = wasActive
        ? await clearAttendance(current.id)
        : await setAttendance(
            SetMapEventAttendanceParams(
              eventId: current.id,
              status: event.status,
            ),
          );

    if (state.eventId != current.id) return;

    result.fold(
      (failure) => emit(state.copyWith(
        // Roll back to what the server last told us.
        event: current,
        action: MapEventAction.none,
        actionError: MapEventErrorMapper.from(failure),
      )),
      (updated) => emit(state.copyWith(
        event: updated,
        action: MapEventAction.none,
        clearActionError: true,
      )),
    );
  }

  /// Keeps the attendee counter honest while the request is in flight, so the
  /// number under the button doesn't lag a beat behind the button itself.
  MapEventEntity _optimisticRsvp(
    MapEventEntity current,
    MapEventAttendance? next,
  ) {
    final was = current.viewer.attendanceStatus;
    final wasCounted = was == MapEventAttendance.attending;
    final willCount = next == MapEventAttendance.attending;

    var count = current.attendeesCount;
    if (wasCounted && !willCount) count -= 1;
    if (!wasCounted && willCount) count += 1;

    return current.copyWith(
      attendanceStatus: next,
      clearAttendance: next == null,
      attendeesCount: count < 0 ? 0 : count,
    );
  }

  // ── Car participation ────────────────────────────────────────────────────

  Future<void> _onRegisterCar(
    RegisterCarForEvent event,
    Emitter<MapEventDetailState> emit,
  ) async {
    final current = state.event;
    if (current == null || state.isBusy) return;

    emit(state.copyWith(
      action: MapEventAction.register,
      clearActionError: true,
    ));

    final result = await registerCar(
      RegisterCarParams(eventId: current.id, carId: event.carId),
    );

    if (state.eventId != current.id) return;

    await result.fold(
      (failure) async => emit(state.copyWith(
        action: MapEventAction.none,
        actionError: MapEventErrorMapper.from(failure),
      )),
      (participant) async {
        // The row is recorded locally first: on a `requires_participant_
        // approval` event it lands as `pending`, and a pending row is exactly
        // what the backend won't show a non-organizer afterwards. Without this
        // the user would tap "participate", succeed, and see no trace of it.
        emit(state.copyWith(
          myParticipations: _mergeParticipations(
            state.myParticipations,
            [participant],
          ),
          action: MapEventAction.none,
        ));
        // POST /cars answers with the participant, not the event, so the
        // counts and viewer flags need a refetch.
        await _load(current.id, emit, keepPreviousOnFailure: true);
      },
    );
  }

  Future<void> _onCancelRegistration(
    CancelPendingCarRegistration event,
    Emitter<MapEventDetailState> emit,
  ) async {
    final current = state.event;
    if (current == null || state.isBusy) return;

    emit(state.copyWith(
      action: MapEventAction.cancelRegistration,
      clearActionError: true,
    ));

    final result = await cancelCarRegistration(
      RegisterCarParams(eventId: current.id, carId: event.carId),
    );

    if (state.eventId != current.id) return;

    await result.fold(
      (failure) async => emit(state.copyWith(
        action: MapEventAction.none,
        actionError: MapEventErrorMapper.from(failure),
      )),
      (_) async {
        emit(state.copyWith(
          myParticipations: [
            for (final p in state.myParticipations)
              if (p.car.id != event.carId) p,
          ],
          unresolvedRegisteredCarIds: [
            for (final id in state.unresolvedRegisteredCarIds)
              if (id != event.carId) id,
          ],
          action: MapEventAction.none,
        ));
        await _load(current.id, emit, keepPreviousOnFailure: true);
      },
    );
  }

  /// Submits the withdrawal request. **One-way**: the backend has no endpoint
  /// for taking it back, so nothing here offers an undo.
  Future<void> _onWithdraw(
    SubmitEventWithdrawal event,
    Emitter<MapEventDetailState> emit,
  ) async {
    final current = state.event;
    if (current == null || state.isBusy) return;

    emit(state.copyWith(
      action: MapEventAction.withdraw,
      clearActionError: true,
    ));

    final result = await withdraw(
      WithdrawFromMapEventParams(eventId: current.id, note: event.note),
    );

    if (state.eventId != current.id) return;

    await result.fold(
      (failure) async => emit(state.copyWith(
        action: MapEventAction.none,
        actionError: MapEventErrorMapper.from(failure),
      )),
      (rows) async {
        emit(state.copyWith(
          myParticipations: _mergeParticipations(state.myParticipations, rows),
          action: MapEventAction.none,
        ));
        await _load(current.id, emit, keepPreviousOnFailure: true);
      },
    );
  }

  void _onClearActionError(
    ClearMapEventActionError event,
    Emitter<MapEventDetailState> emit,
  ) {
    if (state.actionError != null) {
      emit(state.copyWith(clearActionError: true));
    }
  }

  // ── The viewer's own rows ────────────────────────────────────────────────

  /// Works out the status of each car in `viewer.my_registered_car_ids`.
  ///
  /// Accepted rows come free from the entry list that was already fetched.
  /// Anything left over needs the withdrawn slice (also public), and — for an
  /// organizer, who is allowed to see them — the pending and rejected ones.
  /// Ids still unaccounted for after that are a participant's own pending or
  /// rejected entry, which the backend won't disclose to them; they're returned
  /// separately so the UI can say "in progress" instead of inventing a status.
  Future<({List<MapEventParticipantEntity> participations, List<String> unresolvedIds})>
      _resolveMyParticipations(
    MapEventEntity event,
    List<MapEventParticipantEntity> acceptedCars,
  ) async {
    final wanted = event.viewer.myRegisteredCarIds;
    if (wanted.isEmpty) {
      return (participations: const <MapEventParticipantEntity>[], unresolvedIds: const <String>[]);
    }

    final found = <String, MapEventParticipantEntity>{
      for (final p in acceptedCars)
        if (wanted.contains(p.car.id)) p.car.id: p,
    };

    // Anything a session-local write already told us about — a registration
    // made a moment ago that the public list can't show — survives the refetch.
    for (final p in state.myParticipations) {
      if (wanted.contains(p.car.id)) found.putIfAbsent(p.car.id, () => p);
    }

    final statusesToTry = <MapEventParticipation>[
      MapEventParticipation.withdrawn,
      if (event.viewer.isOrganizer) ...[
        MapEventParticipation.pending,
        MapEventParticipation.rejected,
      ],
    ];

    for (final status in statusesToTry) {
      if (found.length == wanted.length) break;
      final page = await getCars(
        GetMapEventCarsParams(
          eventId: event.id,
          status: status,
          size: _carsPageSize,
        ),
      );
      page.forEach((p) {
        for (final row in p.items) {
          if (wanted.contains(row.car.id)) found[row.car.id] = row;
        }
      });
    }

    return (
      participations: [for (final id in wanted) ?found[id]],
      unresolvedIds: [
        for (final id in wanted)
          if (!found.containsKey(id)) id,
      ],
    );
  }

  /// Newer rows win: a freshly-returned `withdrawn` row replaces the `accepted`
  /// one it came from.
  List<MapEventParticipantEntity> _mergeParticipations(
    List<MapEventParticipantEntity> existing,
    List<MapEventParticipantEntity> incoming,
  ) {
    final byCar = <String, MapEventParticipantEntity>{
      for (final p in existing) p.car.id: p,
      for (final p in incoming) p.car.id: p,
    };
    return byCar.values.toList();
  }
}
