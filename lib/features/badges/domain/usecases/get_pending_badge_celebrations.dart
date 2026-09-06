import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_badge.dart';
import '../repositories/badge_repository.dart';

/// Re-fetches the earned badges whose unlock animation is still owed, oldest
/// first. Not used on launch — the first page of `GET /feed/global` already
/// carries the list — only for a mid-session re-check.
@lazySingleton
class GetPendingBadgeCelebrationsUseCase
    implements UseCase<List<UserBadgeEntity>, NoParams> {
  final BadgeRepository repository;

  GetPendingBadgeCelebrationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<UserBadgeEntity>>> call(NoParams params) {
    return repository.getPendingCelebrations();
  }
}
