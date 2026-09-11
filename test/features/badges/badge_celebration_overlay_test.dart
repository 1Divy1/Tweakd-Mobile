import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/core/error/base_failures.dart';
import 'package:tweakd/features/badges/domain/entities/badge.dart';
import 'package:tweakd/features/badges/domain/entities/user_badge.dart';
import 'package:tweakd/features/badges/domain/repositories/badge_repository.dart';
import 'package:tweakd/features/badges/domain/usecases/mark_badge_celebrated.dart';
import 'package:tweakd/features/badges/presentation/bloc/celebration/cubit.dart';
import 'package:tweakd/features/badges/presentation/widgets/badge_celebration_overlay.dart';
import 'package:tweakd/l10n/app_localizations.dart';

/// The overlay sits above the router for the whole app run, so its contract is
/// narrow: draw nothing while the queue is empty, play over the current page
/// when a badge arrives, and on *Continue* acknowledge that badge and get out
/// of the way. Artwork URL is empty on purpose — `BadgeArt` falls back to its
/// medal icon with no network (see profile_layout_test for the why).
void main() {
  UserBadgeEntity userBadge(String id, {required String title}) =>
      UserBadgeEntity(
        badge: BadgeEntity(id: id, title: title, unlockedUrl: ''),
        earnedAt: DateTime.utc(2026, 9, 3, 17),
      );

  Future<BadgeCelebrationCubit> pumpOverlay(
    WidgetTester tester,
    _RecordingBadgeRepository repo,
  ) async {
    final cubit = BadgeCelebrationCubit(MarkBadgeCelebratedUseCase(repo));
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider.value(
          value: cubit,
          child: const BadgeCelebrationOverlay(
            child: Scaffold(body: Center(child: Text('page behind'))),
          ),
        ),
      ),
    );
    return cubit;
  }

  testWidgets('draws nothing until a badge is queued', (tester) async {
    final repo = _RecordingBadgeRepository();
    await pumpOverlay(tester, repo);

    expect(find.text('page behind'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);
  });

  testWidgets(
    'plays the celebration, then Continue acknowledges and dismisses',
    (tester) async {
      final repo = _RecordingBadgeRepository();
      final cubit = await pumpOverlay(tester, repo);

      cubit.enqueue([userBadge('pioneer', title: 'Pioneer')]);
      await tester.pump(); // rebuild with the overlay mounted
      await tester.pump(const Duration(milliseconds: 1200)); // entry animation

      expect(find.text('Pioneer'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pump(); // kick off the reverse
      await tester.pump(
        const Duration(milliseconds: 400),
      ); // reverse + onDismiss

      expect(repo.acknowledged, ['pioneer']);
      expect(find.text('Pioneer'), findsNothing);
      expect(find.text('Continue'), findsNothing);
      expect(find.text('page behind'), findsOneWidget);
    },
  );

  testWidgets('a system back gesture does not dismiss it', (tester) async {
    final repo = _RecordingBadgeRepository();
    final cubit = await pumpOverlay(tester, repo);

    cubit.enqueue([userBadge('pioneer', title: 'Pioneer')]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));

    // Route-level pop request — PopScope(canPop: false) should swallow it.
    final didPop = await tester.binding.handlePopRoute();

    expect(didPop, isTrue); // handled (i.e. absorbed), app not backgrounded
    expect(find.text('Pioneer'), findsOneWidget);
    expect(repo.acknowledged, isEmpty);
  });

  testWidgets('plays a second queued badge after the first is dismissed', (
    tester,
  ) async {
    final repo = _RecordingBadgeRepository();
    final cubit = await pumpOverlay(tester, repo);

    cubit.enqueue([
      userBadge('pioneer', title: 'Pioneer'),
      userBadge('podium', title: 'Podium'),
    ]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.text('Pioneer'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Second badge takes over without leaving the overlay.
    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.text('Podium'), findsOneWidget);
    expect(repo.acknowledged, ['pioneer']);

    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(repo.acknowledged, ['pioneer', 'podium']);
    expect(find.text('Continue'), findsNothing);
  });
}

class _RecordingBadgeRepository implements BadgeRepository {
  final List<String> acknowledged = [];

  @override
  Future<Either<Failure, Unit>> markCelebrated(String badgeId) async {
    acknowledged.add(badgeId);
    return const Right(unit);
  }

  @override
  Future<Either<Failure, List<UserBadgeEntity>>>
  getPendingCelebrations() async => const Right([]);
}
