import 'package:dartz/dartz.dart';

import '../../../../core/error/base_failures.dart';
import '../entities/badge.dart';
import '../entities/user_badge.dart';

abstract class BadgeRepository {
  /// What the signed-in user hasn't unlocked yet. Earned badges come with the
  /// profile — see [BadgeDataSource].
  Future<Either<Failure, List<BadgeEntity>>> getMyLockedBadges();

  /// Earned badges whose one-time unlock animation is still owed, oldest
  /// first. Only needed mid-session — the launch list rides on the feed.
  Future<Either<Failure, List<UserBadgeEntity>>> getPendingCelebrations();

  /// Acknowledges that the unlock animation for [badgeId] has played, so it
  /// stops appearing in [getPendingCelebrations].
  Future<Either<Failure, Unit>> markCelebrated(String badgeId);
}
