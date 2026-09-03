import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/badge.dart';
import '../repositories/badge_repository.dart';

@lazySingleton
class GetMyLockedBadgesUseCase implements UseCase<List<BadgeEntity>, NoParams> {
  final BadgeRepository repository;

  GetMyLockedBadgesUseCase(this.repository);

  @override
  Future<Either<Failure, List<BadgeEntity>>> call(NoParams params) {
    return repository.getMyLockedBadges();
  }
}
