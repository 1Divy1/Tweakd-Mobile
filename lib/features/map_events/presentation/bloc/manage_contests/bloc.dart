import 'dart:async';

import 'package:tweakd/core/error/base_failures.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/contest.dart';
import '../../../domain/usecases/map_event_contests.dart';
import '../../utils/map_event_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// The organizer's contests console: every contest of their event, live rows
/// on the running ones, and the actions that move a contest along — open,
/// extend the planned end, finish, decide entries, delete. A contest only ever
/// opens or closes because the organizer tapped here; nothing is on a timer.
///
/// Every write answers with the contest, so the card updates from the
/// response; nothing here re-reads the list after an action.
@injectable
class ManageContestsBloc extends Bloc<ManageContestsEvent, ManageContestsState> {
  final GetEventContestsUseCase getContests;
  final GetContestUseCase getContest;
  final OpenContestUseCase openContest;
  final FinishContestUseCase finishContest;
  final UpdateContestUseCase updateContest;
  final DecideContestEntryUseCase decideEntry;
  final DeleteContestUseCase deleteContest;
  final ContestLiveUpdates live;

  StreamSubscription? _boards;
  StreamSubscription? _statuses;
  String? _subscribedEventId;

  ManageContestsBloc({
    required this.getContests,
    required this.getContest,
    required this.openContest,
    required this.finishContest,
    required this.updateContest,
    required this.decideEntry,
    required this.deleteContest,
    required this.live,
  }) : super(const ManageContestsState()) {
    on<LoadManagedContests>(_onLoad);
    on<RefreshManagedContests>(_onRefresh);
    on<FinishManagedContest>(_onFinish);
    on<OpenManagedContestNow>(_onOpenNow);
    on<ExtendManagedContest>(_onExtend);
    on<DecideManagedEntry>(_onDecide);
    on<DeleteManagedContest>(_onDelete);
    on<ManagedContestBoardReceived>(_onBoard);
    on<ManagedContestStatusReceived>(_onStatus);
    on<DismissFinishedBanner>(
      (_, emit) => emit(state.copyWith(clearJustFinished: true)),
    );
    on<ClearManageContestsError>(
      (_, emit) => emit(state.copyWith(clearActionError: true)),
    );
  }

  Future<void> _onLoad(
    LoadManagedContests event,
    Emitter<ManageContestsState> emit,
  ) async {
    emit(ManageContestsState(
      status: ManageContestsStatus.loading,
      eventId: event.eventId,
    ));
    await _attach(event.eventId);
    await _load(emit, keepOnFailure: false);
  }

  Future<void> _onRefresh(
    RefreshManagedContests event,
    Emitter<ManageContestsState> emit,
  ) =>
      _load(emit, keepOnFailure: true);

  Future<void> _load(
    Emitter<ManageContestsState> emit, {
    required bool keepOnFailure,
  }) async {
    final eventId = state.eventId;
    if (eventId == null) return;
    final result = await getContests(GetEventContestsParams(eventId: eventId));
    if (state.eventId != eventId) return;
    result.fold(
      (failure) {
        if (keepOnFailure && state.status == ManageContestsStatus.loaded) return;
        emit(state.copyWith(
          status: ManageContestsStatus.failure,
          error: MapEventErrorMapper.from(failure),
        ));
      },
      (contests) => emit(state.copyWith(
        status: ManageContestsStatus.loaded,
        contests: contests,
        clearError: true,
      )),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<void> _onFinish(
    FinishManagedContest event,
    Emitter<ManageContestsState> emit,
  ) async {
    final eventId = state.eventId;
    if (eventId == null) return;
    await _run(event.contestId, emit, () async {
      final result = await finishContest(
        ContestParams(eventId: eventId, contestId: event.contestId),
      );
      return result.map((c) {
        emit(state.copyWith(justFinished: c));
        return c;
      });
    });
  }

  Future<void> _onOpenNow(
    OpenManagedContestNow event,
    Emitter<ManageContestsState> emit,
  ) async {
    final eventId = state.eventId;
    if (eventId == null) return;
    await _run(
      event.contestId,
      emit,
      () => openContest(ContestParams(eventId: eventId, contestId: event.contestId)),
    );
  }

  Future<void> _onExtend(
    ExtendManagedContest event,
    Emitter<ManageContestsState> emit,
  ) async {
    final eventId = state.eventId;
    if (eventId == null) return;
    await _run(event.contestId, emit, () => updateContest(UpdateContestParams(
          eventId: eventId,
          contestId: event.contestId,
          closesAt: event.closesAt,
        )));
  }

  Future<void> _onDecide(
    DecideManagedEntry event,
    Emitter<ManageContestsState> emit,
  ) async {
    final eventId = state.eventId;
    if (eventId == null) return;
    await _run(event.contestId, emit, () => decideEntry(DecideContestEntryParams(
          eventId: eventId,
          contestId: event.contestId,
          carId: event.carId,
          status: event.status,
          reason: event.reason,
        )));
  }

  Future<void> _onDelete(
    DeleteManagedContest event,
    Emitter<ManageContestsState> emit,
  ) async {
    final eventId = state.eventId;
    if (eventId == null || state.busyContestId != null) return;
    emit(state.copyWith(busyContestId: event.contestId, clearActionError: true));
    final result = await deleteContest(
      ContestParams(eventId: eventId, contestId: event.contestId),
    );
    if (state.eventId != eventId) return;
    result.fold(
      (failure) => emit(state.copyWith(
        clearBusy: true,
        actionError: MapEventErrorMapper.from(failure),
      )),
      (_) => emit(state.copyWith(
        clearBusy: true,
        contests: [
          for (final c in state.contests) if (c.id != event.contestId) c,
        ],
      )),
    );
  }

  /// One action at a time; the response replaces the contest it was about.
  Future<void> _run(
    String contestId,
    Emitter<ManageContestsState> emit,
    Future<Either<Failure, ContestEntity>> Function() action,
  ) async {
    if (state.busyContestId != null) return;
    final eventId = state.eventId;
    emit(state.copyWith(busyContestId: contestId, clearActionError: true));
    final result = await action();
    if (state.eventId != eventId) return;
    result.fold(
      (failure) => emit(state.copyWith(
        clearBusy: true,
        actionError: MapEventErrorMapper.from(failure),
      )),
      (contest) => emit(state.copyWith(
        clearBusy: true,
        contests: _replace(contest),
      )),
    );
  }

  List<ContestEntity> _replace(ContestEntity contest) => [
        for (final c in state.contests) c.id == contest.id ? contest : c,
      ];

  // ── Live ─────────────────────────────────────────────────────────────────

  void _onBoard(
    ManagedContestBoardReceived event,
    Emitter<ManageContestsState> emit,
  ) {
    final contest = state.byId(event.board.contestId);
    if (contest == null) return;
    emit(state.copyWith(contests: _replace(contest.applyBoard(event.board))));
  }

  Future<void> _onStatus(
    ManagedContestStatusReceived event,
    Emitter<ManageContestsState> emit,
  ) async {
    final eventId = state.eventId;
    if (eventId == null) return;
    final result = await getContest(
      ContestParams(eventId: eventId, contestId: event.update.contestId),
    );
    if (state.eventId != eventId) return;
    result.fold(
      (_) {},
      (contest) => emit(state.copyWith(contests: _replace(contest))),
    );
  }

  Future<void> _attach(String eventId) async {
    if (_subscribedEventId == eventId) return;
    await _detach();
    _subscribedEventId = eventId;
    _boards = live.boards.listen((b) => add(ManagedContestBoardReceived(b)));
    _statuses =
        live.statusChanges.listen((s) => add(ManagedContestStatusReceived(s)));
    await live.subscribe(eventId);
  }

  Future<void> _detach() async {
    await _boards?.cancel();
    await _statuses?.cancel();
    _boards = null;
    _statuses = null;
    final id = _subscribedEventId;
    _subscribedEventId = null;
    if (id != null) await live.unsubscribe(id);
  }

  @override
  Future<void> close() async {
    await _detach();
    return super.close();
  }
}
