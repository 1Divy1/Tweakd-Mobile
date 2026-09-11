import 'dart:async';

import 'package:tweakd/core/error/base_failures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/contest.dart';
import '../../../domain/usecases/map_event_contests.dart';
import '../../utils/map_event_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// The contests of one event — the CONTESTS tab and the Overview block.
///
/// Owns the event's realtime subscription for as long as it lives: boards
/// land here and are folded into the matching contest; a status change
/// re-reads just that contest. While the channel is down (or never joined) a
/// 30-second poll re-reads the list, but only while something is actually
/// running — a page full of results costs nothing.
@injectable
class EventContestsBloc extends Bloc<EventContestsEvent, EventContestsState> {
  final GetEventContestsUseCase getContests;
  final GetContestUseCase getContest;
  final RequestContestEntryUseCase requestEntry;
  final WithdrawContestEntryUseCase withdrawEntry;
  final ContestLiveUpdates live;

  static const pollInterval = Duration(seconds: 30);

  StreamSubscription? _boards;
  StreamSubscription? _statuses;
  Timer? _poll;
  String? _subscribedEventId;

  EventContestsBloc({
    required this.getContests,
    required this.getContest,
    required this.requestEntry,
    required this.withdrawEntry,
    required this.live,
  }) : super(const EventContestsState()) {
    on<LoadEventContests>(_onLoad);
    on<RefreshEventContests>(_onRefresh);
    on<EventContestBoardReceived>(_onBoard);
    on<EventContestStatusReceived>(_onStatus, transformer: sequential());
    on<EventContestUpdated>(_onUpdated);
    on<SaveContestEntries>(_onSaveEntries);
    on<ClearEventContestsError>(
      (_, emit) => emit(state.copyWith(clearActionError: true)),
    );
  }

  // ── Loading ──────────────────────────────────────────────────────────────

  Future<void> _onLoad(
    LoadEventContests event,
    Emitter<EventContestsState> emit,
  ) async {
    emit(EventContestsState(
      status: EventContestsStatus.loading,
      eventId: event.eventId,
    ));
    await _attach(event.eventId);
    await _load(event.eventId, emit);
  }

  Future<void> _onRefresh(
    RefreshEventContests event,
    Emitter<EventContestsState> emit,
  ) async {
    final id = state.eventId;
    if (id == null) return;
    await _load(id, emit, keepOnFailure: true);
  }

  Future<void> _load(
    String eventId,
    Emitter<EventContestsState> emit, {
    bool keepOnFailure = false,
  }) async {
    final result = await getContests(GetEventContestsParams(eventId: eventId));
    if (state.eventId != eventId) return;
    result.fold(
      (failure) {
        if (keepOnFailure && state.status == EventContestsStatus.loaded) return;
        emit(state.copyWith(
          status: EventContestsStatus.failure,
          error: MapEventErrorMapper.from(failure),
        ));
      },
      (contests) {
        emit(state.copyWith(
          status: EventContestsStatus.loaded,
          contests: contests,
          clearError: true,
        ));
        _schedulePoll();
      },
    );
  }

  // ── Live ─────────────────────────────────────────────────────────────────

  Future<void> _attach(String eventId) async {
    if (_subscribedEventId == eventId) return;
    await _detach();
    _subscribedEventId = eventId;
    _boards = live.boards.listen((b) => add(EventContestBoardReceived(b)));
    _statuses = live.statusChanges.listen(
      (s) => add(EventContestStatusReceived(s)),
    );
    await live.subscribe(eventId);
  }

  Future<void> _detach() async {
    await _boards?.cancel();
    await _statuses?.cancel();
    _boards = null;
    _statuses = null;
    _poll?.cancel();
    _poll = null;
    final id = _subscribedEventId;
    _subscribedEventId = null;
    if (id != null) await live.unsubscribe(id);
  }

  /// Polls only while there is something to watch and the socket isn't
  /// carrying it.
  void _schedulePoll() {
    _poll?.cancel();
    final id = state.eventId;
    if (id == null) return;
    final anythingRunning = state.contests.any((c) => !c.isFinished);
    if (!anythingRunning) return;
    _poll = Timer(pollInterval, () {
      if (isClosed) return;
      if (!live.isLive(id)) add(const RefreshEventContests());
      _schedulePoll();
    });
  }

  void _onBoard(
    EventContestBoardReceived event,
    Emitter<EventContestsState> emit,
  ) {
    final contest = state.byId(event.board.contestId);
    if (contest == null) return;
    _replace(contest.applyBoard(event.board), emit);
  }

  Future<void> _onStatus(
    EventContestStatusReceived event,
    Emitter<EventContestsState> emit,
  ) async {
    final eventId = state.eventId;
    if (eventId == null) return;
    final result = await getContest(
      ContestParams(eventId: eventId, contestId: event.update.contestId),
    );
    if (state.eventId != eventId) return;
    result.fold(
      // A contest that vanished (deleted) is simply dropped on the next poll.
      (_) => add(const RefreshEventContests()),
      (contest) {
        if (state.byId(contest.id) == null) {
          emit(state.copyWith(contests: [...state.contests, contest]));
        } else {
          _replace(contest, emit);
        }
        _schedulePoll();
      },
    );
  }

  void _onUpdated(
    EventContestUpdated event,
    Emitter<EventContestsState> emit,
  ) {
    if (state.byId(event.contest.id) == null) return;
    _replace(event.contest, emit);
  }

  void _replace(ContestEntity contest, Emitter<EventContestsState> emit) {
    emit(state.copyWith(
      contests: [
        for (final c in state.contests) c.id == contest.id ? contest : c,
      ],
    ));
  }

  // ── Entering ─────────────────────────────────────────────────────────────

  Future<void> _onSaveEntries(
    SaveContestEntries event,
    Emitter<EventContestsState> emit,
  ) async {
    final eventId = state.eventId;
    if (eventId == null || state.isSaving) return;
    emit(state.copyWith(isSaving: true, clearActionError: true));

    final requests = <Future<dynamic>>[
      for (final id in event.enterContestIds)
        requestEntry(ContestEntryParams(
          eventId: eventId,
          contestId: id,
          carId: event.carId,
        )),
      for (final id in event.leaveContestIds)
        withdrawEntry(ContestEntryParams(
          eventId: eventId,
          contestId: id,
          carId: event.carId,
        )),
    ];
    final results = await Future.wait(requests);
    if (state.eventId != eventId) return;

    Failure? firstFailure;
    var contests = state.contests;
    for (final r in results) {
      r.fold(
        (f) => firstFailure ??= f as Failure,
        (c) {
          final contest = c as ContestEntity;
          contests = [
            for (final existing in contests)
              existing.id == contest.id ? contest : existing,
          ];
        },
      );
    }
    emit(state.copyWith(
      isSaving: false,
      contests: contests,
      actionError:
          firstFailure == null ? null : MapEventErrorMapper.from(firstFailure!),
    ));
  }

  @override
  Future<void> close() async {
    await _detach();
    return super.close();
  }
}

/// Bloc's `sequential` transformer without importing bloc_concurrency: status
/// re-reads must not interleave, or an older response could overwrite a newer.
EventTransformer<E> sequential<E>() =>
    (events, mapper) => events.asyncExpand(mapper);
