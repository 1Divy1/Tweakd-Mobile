import 'package:tweakd/features/map_events/domain/entities/contest_board_update.dart';
import 'package:tweakd/features/map_events/domain/entities/contest_enums.dart';
import 'package:tweakd/features/map_events/domain/usecases/map_event_contests.dart';
import 'package:tweakd/features/map_events/presentation/bloc/contest_detail/bloc.dart';
import 'package:tweakd/features/map_events/presentation/bloc/contest_detail/event.dart';
import 'package:tweakd/features/map_events/presentation/bloc/contest_detail/state.dart';
import 'package:tweakd/features/map_events/presentation/bloc/event_contests/bloc.dart';
import 'package:tweakd/features/map_events/presentation/bloc/event_contests/event.dart';
import 'package:tweakd/features/map_events/presentation/bloc/event_contests/state.dart';
import 'package:tweakd/features/map_events/presentation/utils/map_event_error_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/contest_fixtures.dart';

/// The vote round trip: optimistic, then the server's copy; a failure
/// restores the copy from before the tap and surfaces the server's sentence;
/// a live board is folded in; a status message re-reads the contest.
void main() {
  late FakeContestsRepository repo;
  late ContestDetailBloc bloc;

  setUp(() {
    repo = FakeContestsRepository(openContest());
    bloc = ContestDetailBloc(
      getContest: GetContestUseCase(repo),
      castVote: CastContestVoteUseCase(repo),
      live: ContestLiveUpdates(repo),
    );
  });

  tearDown(() async {
    await bloc.close();
    await repo.boardsController.close();
    await repo.statusController.close();
  });

  Future<void> load() async {
    bloc.add(LoadContest(eventId: 'm1', contestId: 'k1', initial: openContest()));
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
  }

  test('loading with an initial copy paints at once and subscribes', () async {
    await load();
    expect(bloc.state.status, ContestDetailStatus.loaded);
    expect(bloc.state.contest, isNotNull);
    expect(repo.subscriptions, 1);
    expect(repo.calls, contains('getContest'));
  });

  test('a vote is optimistic, then replaced by the server copy', () async {
    await load();
    repo.next = openContest(voteCarId: 'c3');

    bloc.add(const CastVote('c3'));
    // First emission: the optimistic copy, in flight.
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.isVoting, isFalse); // the fake answers synchronously
    expect(bloc.state.contest!.viewer.voteCarId, 'c3');
    expect(bloc.state.justVotedCarId, 'c3');
    expect(repo.calls, contains('vote:c3'));
  });

  test('a refused vote restores the board and carries the sentence', () async {
    await load();
    final before = bloc.state.contest!;
    repo.failure = ownCarFailure;

    bloc.add(const CastVote('c3'));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.contest, before);
    expect(bloc.state.isVoting, isFalse);
    expect(bloc.state.actionError?.code, MapEventErrorCode.notEligible);
    expect(bloc.state.actionError?.serverMessage, "You can't vote for your own car");
  });

  test('a live board re-ranks the contest on screen', () async {
    await load();
    repo.boardsController.add(ContestBoardUpdate(
      contestId: 'k1',
      status: ContestStatus.open,
      votesCount: 160,
      entries: {
        'c4': ContestBoardRow(votesCount: 90, lastVoteAt: now),
      },
      sentAt: now,
    ));
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.contest!.votesCount, 160);
    expect(bloc.state.contest!.entries.first.car.id, 'c4');
  });

  test('a status change re-reads the contest', () async {
    await load();
    repo.calls.clear();
    repo.next = finishedContest();
    repo.statusController.add(
      const ContestStatusUpdate(contestId: 'k1', status: ContestStatus.finished),
    );
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(repo.calls, ['getContest']);
    expect(bloc.state.contest!.isFinished, isTrue);
  });

  test('closing releases the channel', () async {
    await load();
    await bloc.close();
    expect(repo.subscriptions, 0);
  });

  group('EventContestsBloc', () {
    late EventContestsBloc tab;

    setUp(() {
      tab = EventContestsBloc(
        getContests: GetEventContestsUseCase(repo),
        getContest: GetContestUseCase(repo),
        requestEntry: RequestContestEntryUseCase(repo),
        withdrawEntry: WithdrawContestEntryUseCase(repo),
        live: ContestLiveUpdates(repo),
      );
    });

    tearDown(() => tab.close());

    test('loads, groups by status and merges an updated contest', () async {
      tab.add(const LoadEventContests('m1'));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(tab.state.status, EventContestsStatus.loaded);
      expect(tab.state.open.length, 1);
      expect(tab.state.unvotedOpenCount, 1);

      tab.add(EventContestUpdated(openContest(voteCarId: 'c2')));
      await Future<void>.delayed(Duration.zero);
      expect(tab.state.unvotedOpenCount, 0);
    });

    test('saving entries fires one request per contest and merges results', () async {
      tab.add(const LoadEventContests('m1'));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      repo.calls.clear();

      tab.add(const SaveContestEntries(
        carId: 'c1',
        enterContestIds: {'k1'},
        leaveContestIds: {'k5'},
      ));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(repo.calls, containsAll(['requestEntry:k1', 'withdrawEntry:k5']));
      expect(tab.state.isSaving, isFalse);
      expect(tab.state.actionError, isNull);
    });
  });
}
