// The event page's "Your card" section and the two cubits behind sharing.
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/core/error/base_failures.dart';
import 'package:tweakd/core/services/share_launcher_service.dart';
import 'package:tweakd/features/garage/domain/entities/car_summary.dart';
import 'package:tweakd/features/map_events/domain/entities/participant_card.dart';
import 'package:tweakd/features/map_events/domain/usecases/map_event_contests.dart';
import 'package:tweakd/features/map_events/presentation/bloc/participant_cards/cubit.dart';
import 'package:tweakd/features/map_events/presentation/bloc/share_win/cubit.dart';
import 'package:tweakd/features/map_events/presentation/bloc/share_win/state.dart';
import 'package:tweakd/features/map_events/presentation/widgets/contests/participant_card.dart';
import 'package:tweakd/features/map_events/presentation/widgets/contests/participant_cards_section.dart';
import 'package:tweakd/features/posts/domain/entities/post.dart';
import 'package:tweakd/features/posts/domain/entities/post_params.dart';
import 'package:tweakd/features/posts/domain/failures/post_failures.dart';
import 'package:tweakd/features/posts/domain/repositories/posts_repository.dart';
import 'package:tweakd/features/posts/domain/usecases/share_participant_card.dart';
import 'package:tweakd/l10n/app_localizations.dart';

import 'fakes/contest_fixtures.dart';

const _card = ParticipantCardEntity(
  eventId: 'm1',
  eventTitle: 'Casino Square Cars & Coffee',
  eventAttendeesCount: 247,
  car: CarSummaryEntity(id: 'c1', brand: 'BMW', model: 'M4 Competition'),
  bestRank: 1,
  contests: [
    ParticipantCardContestEntity(contestId: 'k1', title: 'Best paint / wrap', finalRank: 1),
    ParticipantCardContestEntity(contestId: 'k2', title: 'Loudest', finalRank: null),
  ],
);

/// Only the share call is real; anything else would be a test bug.
class _FakePostsRepository implements PostsRepository {
  Either<Failure, PostEntity>? answer;
  ShareParticipantCardParams? lastParams;

  @override
  Future<Either<Failure, PostEntity>> shareParticipantCard(
      ShareParticipantCardParams params) async {
    lastParams = params;
    return answer!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeShareLauncher implements ShareLauncherService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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
  group('ParticipantCardsCubit', () {
    test('loads the viewer\'s cards for the event', () async {
      final repo = FakeContestsRepository(finishedContest())
        ..participantCards = const [_card];
      final cubit = ParticipantCardsCubit(GetMyParticipantCardsUseCase(repo));

      await cubit.load('m1');

      expect(cubit.state.loaded, isTrue);
      expect(cubit.state.cards, const [_card]);
      await cubit.close();
    });

    test('a failed read is quietly no cards, never an error on the page', () async {
      final repo = FakeContestsRepository(finishedContest())
        ..failure = const ServerFailure('boom');
      final cubit = ParticipantCardsCubit(GetMyParticipantCardsUseCase(repo));

      await cubit.load('m1');

      expect(cubit.state.loaded, isTrue);
      expect(cubit.state.cards, isEmpty);
      await cubit.close();
    });
  });

  group('ShareWinCubit.shareCardToFeed', () {
    late _FakePostsRepository posts;
    late ShareWinCubit cubit;

    setUp(() {
      posts = _FakePostsRepository();
      cubit = ShareWinCubit(
        shareCard: ShareParticipantCardUseCase(posts),
        shareLauncher: _FakeShareLauncher(),
      );
    });
    tearDown(() => cubit.close());

    test('sends only which card — event and car — and the caption', () async {
      posts.answer = const Left(ServerFailure('x'));

      await cubit.shareCardToFeed(eventId: 'm1', carId: 'c1', caption: 'What a night');

      expect(posts.lastParams!.toJson(), {
        'event_id': 'm1',
        'car_id': 'c1',
        'description': 'What a night',
      });
    });

    test('a cooldown refusal carries when the card may go out again', () async {
      final next = DateTime(2026, 9, 13, 18, 40);
      posts.answer = Left(ParticipantCardCooldownFailure(next));

      await cubit.shareCardToFeed(eventId: 'm1', carId: 'c1');

      expect(cubit.state.status, ShareWinStatus.cooldown);
      expect(cubit.state.nextAllowedAt, next);
    });

    test('any other failure is a plain failure', () async {
      posts.answer = const Left(ServerFailure('x'));

      await cubit.shareCardToFeed(eventId: 'm1', carId: 'c1');

      expect(cubit.state.status, ShareWinStatus.failure);
    });
  });

  group('ParticipantCardsSection', () {
    Future<ParticipantCardsCubit> loadedCubit(List<ParticipantCardEntity> cards) async {
      final repo = FakeContestsRepository(finishedContest())..participantCards = cards;
      final cubit = ParticipantCardsCubit(GetMyParticipantCardsUseCase(repo));
      await cubit.load('m1');
      return cubit;
    }

    testWidgets('renders nothing without cards (spectators, unfinished events)', (tester) async {
      final cubit = await loadedCubit(const []);
      await tester.pumpWidget(_app(
        BlocProvider.value(value: cubit, child: const ParticipantCardsSection(eventId: 'm1')),
        1.0,
      ));
      expect(find.byType(ParticipantCard), findsNothing);
      await cubit.close();
    });

    for (final width in const [320.0, 375.0, 430.0]) {
      for (final textScale in const [1.0, 1.3, 2.0]) {
        testWidgets('lays out at ${width.toInt()}pt, text x$textScale', (tester) async {
          tester.view.physicalSize = Size(width * 3, 1800 * 3);
          tester.view.devicePixelRatio = 3;
          addTearDown(tester.view.reset);
          final cubit = await loadedCubit(const [_card, _card]);

          await tester.pumpWidget(_app(
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: BlocProvider.value(
                value: cubit,
                child: const ParticipantCardsSection(eventId: 'm1'),
              ),
            ),
            textScale,
          ));
          await tester.pump();

          expect(tester.takeException(), isNull);
          expect(find.byType(ParticipantCard), findsNWidgets(2));
          await cubit.close();
        });
      }
    }
  });
}
