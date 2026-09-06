import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/badge_repository.dart';

class MarkBadgeCelebratedParams extends Equatable {
  final String badgeId;
  const MarkBadgeCelebratedParams(this.badgeId);

  @override
  List<Object?> get props => [badgeId];
}

/// Tells the backend the unlock animation for one badge has played, so it is
/// not shown again. Idempotent server-side; a failure here just means the
/// badge reappears on the next launch's feed payload.
@lazySingleton
class MarkBadgeCelebratedUseCase
    implements UseCase<Unit, MarkBadgeCelebratedParams> {
  final BadgeRepository repository;

  MarkBadgeCelebratedUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(MarkBadgeCelebratedParams params) {
    return repository.markCelebrated(params.badgeId);
  }
}
