import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/map_event_contests.dart';
import '../../utils/map_event_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// One contest's page: the board, the viewer's vote, the live updates.
///
/// Voting is optimistic-then-authoritative: the tap moves the board and marks
/// the choice immediately, the server's `ContestDto` replaces the whole thing
/// when it lands, and a failure restores the copy from before the tap with the
/// server's sentence in a snackbar. A board that arrives while a vote is in
/// flight is applied on top of the optimistic copy — the server response
/// wins last anyway.
@injectable
class ContestDetailBloc extends Bloc<ContestDetailEvent, ContestDetailState> {
  final GetContestUseCase getContest;
  final CastContestVoteUseCase castVote;
  final ContestLiveUpdates live;

  StreamSubscription? _boards;
  StreamSubscription? _statuses;
  String? _subscribedEventId;

  ContestDetailBloc({
    required this.getContest,
    required this.castVote,
    required this.live,
  }) : super(const ContestDetailState()) {
    on<LoadContest>(_onLoad);
    on<RefreshContest>(_onRefresh);
    on<CastVote>(_onVote);
    on<ContestBoardReceived>(_onBoard);
    on<ContestStatusReceived>(_onStatus);
    on<ClearContestActionError>(
      (_, emit) => emit(state.copyWith(clearActionError: true, clearJustVoted: true)),
    );
  }

  Future<void> _onLoad(LoadContest event, Emitter<ContestDetailState> emit) async {
    emit(ContestDetailState(
      status: event.initial == null
          ? ContestDetailStatus.loading
          : ContestDetailStatus.loaded,
      eventId: event.eventId,
      contestId: event.contestId,
      contest: event.initial,
    ));
    await _attach(event.eventId);
    await _load(emit, keepOnFailure: event.initial != null);
  }

  Future<void> _onRefresh(
    RefreshContest event,
    Emitter<ContestDetailState> emit,
  ) =>
      _load(emit, keepOnFailure: true);

  Future<void> _load(
    Emitter<ContestDetailState> emit, {
    required bool keepOnFailure,
  }) async {
    final eventId = state.eventId;
    final contestId = state.contestId;
    if (eventId == null || contestId == null) return;
    final result = await getContest(
      ContestParams(eventId: eventId, contestId: contestId),
    );
    if (state.contestId != contestId) return;
    result.fold(
      (failure) {
        if (keepOnFailure && state.contest != null) return;
        emit(state.copyWith(
          status: ContestDetailStatus.failure,
          error: MapEventErrorMapper.from(failure),
        ));
      },
      (contest) => emit(state.copyWith(
        status: ContestDetailStatus.loaded,
        contest: contest,
        clearError: true,
      )),
    );
  }

  Future<void> _onVote(CastVote event, Emitter<ContestDetailState> emit) async {
    final before = state.contest;
    final eventId = state.eventId;
    if (before == null || eventId == null || state.isVoting) return;
    if (before.viewer.voteCarId == event.carId) return;

    emit(state.copyWith(
      contest: before.applyOptimisticVote(event.carId),
      isVoting: true,
      clearActionError: true,
      clearJustVoted: true,
    ));

    final result = await castVote(ContestEntryParams(
      eventId: eventId,
      contestId: before.id,
      carId: event.carId,
    ));
    if (state.contestId != before.id) return;
    result.fold(
      (failure) => emit(state.copyWith(
        contest: before,
        isVoting: false,
        actionError: MapEventErrorMapper.from(failure),
      )),
      (contest) => emit(state.copyWith(
        contest: contest,
        isVoting: false,
        justVotedCarId: event.carId,
      )),
    );
  }

  void _onBoard(ContestBoardReceived event, Emitter<ContestDetailState> emit) {
    final contest = state.contest;
    if (contest == null || contest.id != event.board.contestId) return;
    emit(state.copyWith(contest: contest.applyBoard(event.board)));
  }

  Future<void> _onStatus(
    ContestStatusReceived event,
    Emitter<ContestDetailState> emit,
  ) async {
    if (event.update.contestId != state.contestId) return;
    await _load(emit, keepOnFailure: true);
  }

  Future<void> _attach(String eventId) async {
    if (_subscribedEventId == eventId) return;
    await _detach();
    _subscribedEventId = eventId;
    _boards = live.boards.listen((b) => add(ContestBoardReceived(b)));
    _statuses = live.statusChanges.listen((s) => add(ContestStatusReceived(s)));
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
