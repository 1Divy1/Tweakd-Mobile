import 'package:dartz/dartz.dart';

import '../../../../core/error/base_failures.dart';
import '../entities/user_badge.dart';

abstract class BadgeRepository {
  /// Earned badges whose one-time unlock animation is still owed, oldest
  /// first. Only needed mid-session — the launch list rides on the feed.
  Future<Either<Failure, List<UserBadgeEntity>>> getPendingCelebrations();

  /// Acknowledges that the unlock animation for [badgeId] has played, so it
  /// stops appearing in [getPendingCelebrations].
  Future<Either<Failure, Unit>> markCelebrated(String badgeId);
}
