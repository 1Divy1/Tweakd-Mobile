import 'package:dartz/dartz.dart';

import '../../../../core/error/base_failures.dart';
import '../entities/badge.dart';

abstract class BadgeRepository {
  /// What the signed-in user hasn't unlocked yet. Earned badges come with the
  /// profile — see [BadgeDataSource].
  Future<Either<Failure, List<BadgeEntity>>> getMyLockedBadges();
}
