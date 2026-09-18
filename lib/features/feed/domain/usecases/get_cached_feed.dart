import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/feed_page.dart';
import '../repositories/feed_repository.dart';

/// The last fetched first page of the feed, straight from the device, or null
/// when there is none. Always a [Right]: the cache is optional by design.
@lazySingleton
class GetCachedFeedUseCase implements UseCase<FeedPageEntity?, NoParams> {
  final FeedRepository repository;

  GetCachedFeedUseCase(this.repository);

  @override
  Future<Either<Failure, FeedPageEntity?>> call(NoParams params) async =>
      Right(await repository.getCachedFirstPage());
}
