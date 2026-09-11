import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/core/error/base_failures.dart';
import 'package:tweakd/features/badges/domain/entities/badge.dart';
import 'package:tweakd/features/badges/domain/entities/user_badge.dart';
import 'package:tweakd/features/badges/domain/repositories/badge_repository.dart';
import 'package:tweakd/features/badges/domain/usecases/mark_badge_celebrated.dart';
import 'package:tweakd/features/badges/presentation/bloc/celebration/cubit.dart';

/// The cubit is the whole safety net around the animation firing exactly once:
/// it de-duplicates re-delivered badges (a feed refresh before the ack lands),
/// acknowledges each one as it is dismissed, and clears on sign-out.
void main() {
  UserBadgeEntity badge(String id) => UserBadgeEntity(
    badge: BadgeEntity(id: id, title: id, unlockedUrl: ''),
    earnedAt: DateTime.utc(2026, 9, 3, 17),
  );

  late _RecordingBadgeRepository repo;
  late BadgeCelebrationCubit cubit;

  setUp(() {
    repo = _RecordingBadgeRepository();
    cubit = BadgeCelebrationCubit(MarkBadgeCelebratedUseCase(repo));
  });

  tearDown(() => cubit.close());

  test('enqueue fills the queue oldest-first', () {
    cubit.enqueue([badge('pioneer'), badge('podium')]);

    expect(cubit.state.queue.map((b) => b.badge.id), ['pioneer', 'podium']);
    expect(cubit.state.current?.badge.id, 'pioneer');
  });

  test('a badge already seen this run is not re-queued', () {
    cubit.enqueue([badge('pioneer')]);
    cubit.dismissCurrent(); // queue now empty, 'pioneer' remembered

    cubit.enqueue([badge('pioneer'), badge('podium')]);

    expect(cubit.state.queue.map((b) => b.badge.id), ['podium']);
  });

  test('dismissCurrent acknowledges the badge and advances', () {
    cubit.enqueue([badge('pioneer'), badge('podium')]);

    cubit.dismissCurrent();

    expect(repo.acknowledged, ['pioneer']);
    expect(cubit.state.current?.badge.id, 'podium');

    cubit.dismissCurrent();

    expect(repo.acknowledged, ['pioneer', 'podium']);
    expect(cubit.state.isShowing, isFalse);
  });

  test('dismissCurrent on an empty queue is a no-op', () {
    cubit.dismissCurrent();

    expect(repo.acknowledged, isEmpty);
    expect(cubit.state.isShowing, isFalse);
  });

  test('reset clears the queue and forgets what was seen', () {
    cubit.enqueue([badge('pioneer')]);
    cubit.reset();

    expect(cubit.state.isShowing, isFalse);

    // 'pioneer' can celebrate again for the next user on this device.
    cubit.enqueue([badge('pioneer')]);
    expect(cubit.state.current?.badge.id, 'pioneer');
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
