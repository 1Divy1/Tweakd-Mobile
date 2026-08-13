import 'package:car_social_media_app/core/error/base_failures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/map_event.dart';
import '../../../domain/entities/map_event_enums.dart';
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
/// Two contract facts shape most of this file:
///
/// * **Every write answers with the whole event.** RSVP, registration,
///   cancellation and withdrawal all come back as a fresh `MapEventDto`, so a
///   write is optimistic-then-authoritative and never needs a follow-up GET
///   for counts or viewer flags.
/// * **The viewer's own entries come from `GET /{id}/cars/mine`.** That list
///   carries every status the caller has in the event — including the pending
///   and rejected rows the public entry list keeps to organizers — plus the
///   organizer's `rejection_reason`. It's the one call behind every "your
///   entry" strip, and it's re-read after any write that could move a row.
@injectable
class MapEventDetailBloc
    extends Bloc<MapEventDetailEvent, MapEventDetailState> {
  final GetMapEventUseCase getEvent;
  final GetMapEventAttendeesUseCase getAttendees;
  final GetMapEventCarsUseCase getCars;
  final GetMyMapEventCarsUseCase getMyCars;
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
    required this.getMyCars,
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

  /// Fetches the event, its attendee preview, the first page of the entry list
  /// and the viewer's own entries. The four requests overlap; only the event's
  /// failure is fatal — a missing avatar row is not worth an error screen.
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
    final myCarsRequest = getMyCars(GetMyMapEventCarsParams(eventId: eventId));

    final eventResult = await eventRequest;
    final attendeesResult = await attendeesRequest;
    final carsResult = await carsRequest;
    final myCarsResult = await myCarsRequest;

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

    emit(state.copyWith(
      status: MapEventDetailStatus.loaded,
      event: loaded,
      clearError: true,
      attendeePreview:
          attendeesResult.toOption().toNullable()?.items ?? const [],
      cars: carsPage?.items ?? const [],
      carsNextCursor: carsPage?.nextCursor,
      clearCarsCursor: carsPage?.nextCursor == null,
      isLoadingCars: false,
      // A failed "mine" call leaves the strips off rather than showing a stale
      // status from before the write that triggered this load.
      myParticipations:
          myCarsResult.toOption().toNullable() ?? const [],
      action: MapEventAction.none,
    ));
  }

  /// What a participation write needs afterwards. The event itself came back
  /// in the write's own response, so this only re-reads the two lists a
  /// registration or withdrawal can move: the public entry list and the
  /// viewer's own rows.
  ///
  /// It also clears the in-flight action, so the participation button stays
  /// busy until the row that decides its label has actually landed — clearing
  /// it on the write's response would flash "PARTICIPATE?" at someone who just
  /// registered.
  Future<void> _reloadEntryLists(
    String eventId,
    Emitter<MapEventDetailState> emit,
  ) async {
    final carsRequest = getCars(
      GetMapEventCarsParams(
        eventId: eventId,
        status: MapEventParticipation.accepted,
        size: _carsPageSize,
      ),
    );
    final myCarsRequest = getMyCars(GetMyMapEventCarsParams(eventId: eventId));

    final carsResult = await carsRequest;
    final myCarsResult = await myCarsRequest;

    if (state.eventId != eventId) return;

    final carsPage = carsResult.toOption().toNullable();

    emit(state.copyWith(
      cars: carsPage?.items ?? state.cars,
      carsNextCursor: carsPage?.nextCursor,
      clearCarsCursor: carsPage?.nextCursor == null,
      myParticipations:
          myCarsResult.toOption().toNullable() ?? state.myParticipations,
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
      (updated) async {
        // The response is the whole event, so the counts and viewer flags are
        // already authoritative; only the two car lists still need re-reading,
        // and the button stays busy until they land.
        emit(state.copyWith(event: updated));
        await _reloadEntryLists(updated.id, emit);
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
      (updated) async {
        // Drop the row locally so the strip goes as soon as the button does;
        // `/cars/mine` confirms it a moment later.
        emit(state.copyWith(
          event: updated,
          myParticipations: [
            for (final p in state.myParticipations)
              if (p.car.id != event.carId) p,
          ],
        ));
        await _reloadEntryLists(updated.id, emit);
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
      (updated) async {
        emit(state.copyWith(event: updated));
        await _reloadEntryLists(updated.id, emit);
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
}
