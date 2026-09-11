import 'package:tweakd/features/map_events/domain/entities/contest_enums.dart';
import 'package:tweakd/features/map_events/domain/usecases/map_event_contests.dart';
import 'package:tweakd/features/map_events/presentation/bloc/manage_contests/bloc.dart';
import 'package:tweakd/features/map_events/presentation/bloc/manage_contests/event.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/contest_fixtures.dart';

/// The organizer's console moves a contest by hand, and only by hand: opening
/// voting is its own call, and moving the planned closing time is an ordinary
/// edit that leaves the contest exactly where it was.
void main() {
  late FakeContestsRepository repo;
  late ManageContestsBloc bloc;

  setUp(() {
    repo = FakeContestsRepository(scheduledContest());
    bloc = ManageContestsBloc(
      getContests: GetEventContestsUseCase(repo),
      getContest: GetContestUseCase(repo),
      openContest: OpenContestUseCase(repo),
      finishContest: FinishContestUseCase(repo),
      updateContest: UpdateContestUseCase(repo),
      decideEntry: DecideContestEntryUseCase(repo),
      deleteContest: DeleteContestUseCase(repo),
      live: ContestLiveUpdates(repo),
    );
  });

  tearDown(() async {
    await bloc.close();
    await repo.boardsController.close();
    await repo.statusController.close();
  });

  Future<void> load() async {
    bloc.add(const LoadManagedContests('m1'));
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
  }

  Future<void> settle() async {
    for (var i = 0; i < 4; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  test('opening voting calls the open endpoint, not an opens_at edit', () async {
    await load();
    repo.calls.clear();
    repo.next = scheduledContest(status: ContestStatus.open);

    bloc.add(const OpenManagedContestNow('k5'));
    await settle();

    expect(repo.calls, contains('openContest'));
    expect(repo.calls, isNot(contains('updateContest')));
    expect(bloc.state.contests.single.isOpen, isTrue);
  });

  test('extending only moves the planned close', () async {
    await load();
    repo.calls.clear();
    repo.next = scheduledContest();

    bloc.add(ExtendManagedContest('k5', DateTime.now().add(const Duration(hours: 2))));
    await settle();

    expect(repo.calls, contains('updateContest'));
    expect(bloc.state.contests.single.isScheduled, isTrue);
  });
}
