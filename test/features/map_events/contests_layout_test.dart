// Responsiveness guard for every new contest surface, pumped across a width ×
// text-scale matrix the way test/features/profile/profile_layout_test.dart
// does. Widget tests render a fixed-width test font, so every glyph is as wide
// as it is tall — a harsher squeeze than any device.
import 'package:tweakd/features/garage/presentation/widgets/car_events_section.dart';
import 'package:tweakd/features/map_events/domain/usecases/map_event_contests.dart';
import 'package:tweakd/features/map_events/presentation/bloc/car_event_history/bloc.dart';
import 'package:tweakd/features/map_events/presentation/bloc/car_event_history/event.dart';
import 'package:tweakd/features/map_events/presentation/bloc/contest_detail/bloc.dart';
import 'package:tweakd/features/map_events/presentation/bloc/contest_detail/event.dart';
import 'package:tweakd/features/map_events/presentation/bloc/event_contests/state.dart';
import 'package:tweakd/features/map_events/presentation/pages/contest_page.dart';
import 'package:tweakd/features/map_events/presentation/widgets/contests/contest_card.dart';
import 'package:tweakd/features/map_events/presentation/widgets/contests/contests_tab.dart';
import 'package:tweakd/features/map_events/presentation/widgets/contests/org_contest_card.dart';
import 'package:tweakd/features/map_events/presentation/widgets/contests/participant_card.dart';
import 'package:tweakd/features/map_events/presentation/widgets/contests/winner_reveal.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/contest_fixtures.dart';

Widget _app(Widget body, double textScale) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: true,
        ),
        child: child!,
      ),
      home: Scaffold(body: body),
    );

void main() {
  const widths = [320.0, 375.0, 430.0, 768.0];
  const textScales = [1.0, 1.3, 2.0];

  final tabState = EventContestsState(
    status: EventContestsStatus.loaded,
    eventId: 'm1',
    contests: [openContest(), scheduledContest(), finishedContest(viewerWon: true)],
  );

  for (final width in widths) {
    for (final textScale in textScales) {
      final label = '${width.toInt()}pt, text x$textScale';

      testWidgets('contests tab and cards lay out at $label', (tester) async {
        tester.view.physicalSize = Size(width * 3, 1400 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(_app(
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ContestsTab(
              state: tabState,
              now: now,
              myCarName: 'BMW M4 Competition',
              showEnter: true,
              onOpen: (_) {},
              onEnter: () {},
            ),
          ),
          textScale,
        ));
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.byType(ContestCard), findsNWidgets(3));
        expect(find.text('Best exhaust system'), findsWidgets);
      });

      testWidgets('winner reveal and participant card lay out at $label',
          (tester) async {
        tester.view.physicalSize = Size(width * 3, 1400 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);

        final finished = finishedContest(viewerWon: true);
        await tester.pumpWidget(_app(
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                WinnerReveal(contest: finished, onShare: () {}),
                const SizedBox(height: 16),
                Center(
                  child: ParticipantCard(
                    data: participantCardData(contestCount: 2),
                    width: (width - 32).clamp(240, 340),
                  ),
                ),
              ],
            ),
          ),
          textScale,
        ));
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text('BMW M4 Competition'), findsWidgets);
      });

      // The owner's hard constraint: the card is the same height whatever the
      // contest count, because the contests row is always one line. Zero
      // contests is the documented exception — that row drops entirely.
      testWidgets('participant card keeps one height at $label', (tester) async {
        tester.view.physicalSize = Size(width * 3, 1400 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);

        final cardWidth = (width - 32).clamp(240.0, 340.0);
        final heights = <int, double>{};
        for (final count in [1, 2, 3, 6, 9]) {
          await tester.pumpWidget(_app(
            Center(
              child: ParticipantCard(
                data: participantCardData(contestCount: count),
                width: cardWidth,
              ),
            ),
            textScale,
          ));
          await tester.pump();
          expect(tester.takeException(), isNull);
          heights[count] =
              tester.getSize(find.byType(ParticipantCard)).height;
        }
        expect(
          heights.values.toSet(),
          hasLength(1),
          reason: 'card height drifted with contest count: $heights',
        );

        // And a participant who entered nothing still renders, one row shorter.
        await tester.pumpWidget(_app(
          Center(
            child: ParticipantCard(
              data: participantCardData(contestCount: 0),
              width: cardWidth,
            ),
          ),
          textScale,
        ));
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(
          tester.getSize(find.byType(ParticipantCard)).height,
          lessThan(heights[1]!),
        );
      });

      // No placement anywhere => no pill, which is the whole point of giving
      // non-winners a card.
      testWidgets('participant card hides the pill off-podium at $label',
          (tester) async {
        tester.view.physicalSize = Size(width * 3, 1400 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(_app(
          Center(
            child: ParticipantCard(
              data: participantCardData(contestCount: 3, onPodium: false),
              width: (width - 32).clamp(240.0, 340.0),
            ),
          ),
          textScale,
        ));
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.byIcon(Icons.emoji_events_rounded), findsNothing);
      });

      testWidgets('organizer card lays out at $label', (tester) async {
        tester.view.physicalSize = Size(width * 3, 1400 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);

        void noop() {}
        void noopId(String _) {}
        await tester.pumpWidget(_app(
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (final c in [openContest(), scheduledContest(), finishedContest()])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: OrgContestCard(
                      contest: c,
                      now: now,
                      isBusy: false,
                      onOpen: noop,
                      onFinish: noop,
                      onOpenNow: noop,
                      onExtend: noop,
                      onEdit: noop,
                      onDelete: noop,
                      onAccept: noopId,
                      onDecline: noopId,
                    ),
                  ),
              ],
            ),
          ),
          textScale,
        ));
        await tester.pump();
        expect(tester.takeException(), isNull);
      });

      testWidgets('contest page lays out at $label', (tester) async {
        tester.view.physicalSize = Size(width * 3, 900 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);

        final repo = FakeContestsRepository(openContest(voteCarId: 'c2'));
        addTearDown(() async {
          await repo.boardsController.close();
          await repo.statusController.close();
        });
        final bloc = ContestDetailBloc(
          getContest: GetContestUseCase(repo),
          castVote: CastContestVoteUseCase(repo),
          live: ContestLiveUpdates(repo),
        )..add(LoadContest(eventId: 'm1', contestId: 'k1', initial: openContest(voteCarId: 'c2')));
        addTearDown(bloc.close);

        await tester.pumpWidget(_app(
          BlocProvider<ContestDetailBloc>.value(
            value: bloc,
            child: const ContestPage(eventId: 'm1', eventTitle: 'Casino Square Cars & Coffee'),
          ),
          textScale,
        ));
        await tester.pump();
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text('Best exhaust system'), findsWidgets);
      });

      testWidgets('car events section lays out at $label', (tester) async {
        tester.view.physicalSize = Size(width * 3, 1200 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);

        final repo = FakeContestsRepository(openContest());
        addTearDown(() async {
          await repo.boardsController.close();
          await repo.statusController.close();
        });
        final bloc = CarEventHistoryBloc(getHistory: GetCarEventHistoryUseCase(repo))
          ..add(const LoadCarEventHistory('c1'));
        addTearDown(bloc.close);

        await tester.pumpWidget(_app(
          BlocProvider<CarEventHistoryBloc>.value(
            value: bloc,
            child: const SingleChildScrollView(child: CarEventsSection()),
          ),
          textScale,
        ));
        await tester.pump();
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text('Casino Square Cars & Coffee'), findsOneWidget);
      });
    }
  }
}
