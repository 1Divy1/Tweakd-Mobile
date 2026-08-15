import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/map_event_enums.dart';
import '../../../domain/usecases/manage_map_event.dart';
import '../../../domain/usecases/map_event_organizers.dart';
import '../../../domain/usecases/map_event_participation.dart';
import '../../../domain/usecases/map_event_reads.dart';
import '../../../domain/usecases/map_event_withdrawals.dart';
import '../../utils/map_event_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// The organizer's console for one event: the two approval queues, the
/// organizer list, and the cancel / finish / delete actions.
///
/// Everything here is behind a 403 for anyone who isn't an organizer — the
/// pending-entry list and the withdrawal queue included — so the page is only
/// ever reachable from the detail page's organizer-gated button.
@injectable
class ManageMapEventBloc
    extends Bloc<ManageMapEventEvent, ManageMapEventState> {
  final GetMapEventUseCase getEvent;
  final GetMapEventCarsUseCase getCars;
  final GetMapEventWithdrawalsUseCase getWithdrawals;
  final ReviewCarRegistrationUseCase reviewCar;
  final ApproveWithdrawalUseCase approveWithdrawal;
  final RejectWithdrawalUseCase rejectWithdrawal;
  final RemoveMapEventOrganizerUseCase removeOrganizer;
  final CancelMapEventUseCase cancelEvent;
  final FinishMapEventUseCase finishEvent;
  final DeleteMapEventUseCase deleteEvent;

  static const _pageSize = 50;

  String _eventId = '';

  ManageMapEventBloc({
    required this.getEvent,
    required this.getCars,
    required this.getWithdrawals,
    required this.reviewCar,
    required this.approveWithdrawal,
    required this.rejectWithdrawal,
    required this.removeOrganizer,
    required this.cancelEvent,
    required this.finishEvent,
    required this.deleteEvent,
  }) : super(const ManageMapEventState()) {
    on<LoadMapEventManagement>(_onLoad);
    on<RefreshMapEventManagement>(_onRefresh);
    on<ReviewEntry>(_onReviewEntry);
    on<ReviewWithdrawal>(_onReviewWithdrawal);
    on<RemoveManagedOrganizer>(_onRemoveOrganizer);
    on<RunEventLifecycleAction>(_onLifecycleAction);
    on<ClearManageEventError>(
      (e, emit) => emit(state.copyWith(clearActionError: true)),
    );
  }

  Future<void> _onLoad(
    LoadMapEventManagement event,
    Emitter<ManageMapEventState> emit,
  ) async {
    _eventId = event.eventId;
    emit(state.copyWith(status: ManageMapEventStatus.loading, clearError: true));
    await _fetch(emit);
  }

  Future<void> _onRefresh(
    RefreshMapEventManagement event,
    Emitter<ManageMapEventState> emit,
  ) =>
      _fetch(emit);

  /// The three requests overlap. Only the event's failure is fatal: a queue
  /// that won't load leaves the rest of the page usable.
  Future<void> _fetch(Emitter<ManageMapEventState> emit) async {
    final eventRequest = getEvent(GetMapEventParams(eventId: _eventId));
    final entriesRequest = getCars(
      GetMapEventCarsParams(
        eventId: _eventId,
        status: MapEventParticipation.pending,
        size: _pageSize,
      ),
    );
    final withdrawalsRequest = getWithdrawals(_eventId);

    final eventResult = await eventRequest;
    final entriesResult = await entriesRequest;
    final withdrawalsResult = await withdrawalsRequest;

    final loaded = eventResult.toOption().toNullable();
    if (loaded == null) {
      emit(state.copyWith(
        status: ManageMapEventStatus.failure,
        error: MapEventErrorMapper.from(
          eventResult.fold((f) => f, (_) => throw StateError('unreachable')),
        ),
      ));
      return;
    }

    emit(state.copyWith(
      status: ManageMapEventStatus.loaded,
      event: loaded,
      pendingEntries: entriesResult.toOption().toNullable()?.items ?? const [],
      withdrawals: withdrawalsResult.toOption().toNullable() ?? const [],
      clearError: true,
    ));
  }

  // ── Entry queue ──────────────────────────────────────────────────────────

  Future<void> _onReviewEntry(
    ReviewEntry event,
    Emitter<ManageMapEventState> emit,
  ) async {
    if (state.busyIds.contains(event.carId)) return;
    emit(state.copyWith(busyIds: {...state.busyIds, event.carId}));

    final result = await reviewCar(
      ReviewCarRegistrationParams(
        eventId: _eventId,
        carId: event.carId,
        status: event.accept
            ? MapEventParticipation.accepted
            : MapEventParticipation.rejected,
        reason: event.reason,
      ),
    );

    final stillBusy = {...state.busyIds}..remove(event.carId);

    result.fold(
      (failure) => emit(state.copyWith(
        busyIds: stillBusy,
        actionError: MapEventErrorMapper.from(failure),
      )),
      // The endpoint answers with the whole event — new `attending_cars_count`
      // included — and the row leaves the pending queue either way, so there is
      // nothing left to refetch.
      (updated) => emit(state.copyWith(
        busyIds: stillBusy,
        event: updated,
        pendingEntries: [
          for (final p in state.pendingEntries)
            if (p.car.id != event.carId) p,
        ],
      )),
    );
  }

  // ── Withdrawal queue ─────────────────────────────────────────────────────

  Future<void> _onReviewWithdrawal(
    ReviewWithdrawal event,
    Emitter<ManageMapEventState> emit,
  ) async {
    if (state.busyIds.contains(event.ownerId)) return;
    emit(state.copyWith(busyIds: {...state.busyIds, event.ownerId}));

    final params =
        ReviewWithdrawalParams(eventId: _eventId, ownerId: event.ownerId);
    final result = event.approve
        ? await approveWithdrawal(params)
        : await rejectWithdrawal(params);

    final stillBusy = {...state.busyIds}..remove(event.ownerId);

    result.fold(
      (failure) => emit(state.copyWith(
        busyIds: stillBusy,
        actionError: MapEventErrorMapper.from(failure),
      )),
      // Both answers carry the updated event, so the entry count moves without
      // a refetch and the request drops out of the queue locally.
      (updated) => emit(state.copyWith(
        busyIds: stillBusy,
        event: updated,
        withdrawals: [
          for (final w in state.withdrawals)
            if (w.ownerId != event.ownerId) w,
        ],
      )),
    );
  }

  // ── Organizers ───────────────────────────────────────────────────────────

  Future<void> _onRemoveOrganizer(
    RemoveManagedOrganizer event,
    Emitter<ManageMapEventState> emit,
  ) async {
    if (state.busyIds.contains(event.organizerId)) return;
    emit(state.copyWith(busyIds: {...state.busyIds, event.organizerId}));

    final result = await removeOrganizer(
      RemoveMapEventOrganizerParams(
        eventId: _eventId,
        organizerId: event.organizerId,
      ),
    );

    final stillBusy = {...state.busyIds}..remove(event.organizerId);

    result.fold(
      (failure) => emit(state.copyWith(
        busyIds: stillBusy,
        actionError: MapEventErrorMapper.from(failure),
      )),
      // The endpoint answers with the updated event, so there's nothing to
      // refetch here.
      (updated) => emit(state.copyWith(busyIds: stillBusy, event: updated)),
    );
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────

  Future<void> _onLifecycleAction(
    RunEventLifecycleAction event,
    Emitter<ManageMapEventState> emit,
  ) async {
    const key = 'lifecycle';
    if (state.busyIds.contains(key)) return;
    emit(state.copyWith(busyIds: {...state.busyIds, key}));

    final stillBusy = {...state.busyIds}..remove(key);

    switch (event.action) {
      case MapEventLifecycleAction.cancel:
        final result = await cancelEvent(_eventId);
        result.fold(
          (failure) => emit(state.copyWith(
            busyIds: stillBusy,
            actionError: MapEventErrorMapper.from(failure),
          )),
          (updated) => emit(state.copyWith(busyIds: stillBusy, event: updated)),
        );
      case MapEventLifecycleAction.finish:
        final result = await finishEvent(_eventId);
        result.fold(
          (failure) => emit(state.copyWith(
            busyIds: stillBusy,
            actionError: MapEventErrorMapper.from(failure),
          )),
          (updated) => emit(state.copyWith(busyIds: stillBusy, event: updated)),
        );
      case MapEventLifecycleAction.delete:
        final result = await deleteEvent(_eventId);
        result.fold(
          (failure) => emit(state.copyWith(
            busyIds: stillBusy,
            actionError: MapEventErrorMapper.from(failure),
          )),
          // Nothing left to show: the page pops on this flag.
          (_) => emit(state.copyWith(busyIds: stillBusy, isDeleted: true)),
        );
    }
  }
}
