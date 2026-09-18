import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/feed_repository.dart';

/// Deletes the cached first page of the feed, so nothing the previous user saw
/// is left on the device after they sign out.
@lazySingleton
class ClearFeedCacheUseCase implements UseCase<Unit, NoParams> {
  final FeedRepository repository;

  ClearFeedCacheUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    await repository.clearCache();
    return const Right(unit);
  }
}
