import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/feed_page.dart';
import '../repositories/feed_repository.dart';

class GetGlobalFeedParams {
  final String? cursor;
  final int size;
  const GetGlobalFeedParams({this.cursor, this.size = 20});
}

@lazySingleton
class GetGlobalFeedUseCase
    implements UseCase<FeedPageEntity, GetGlobalFeedParams> {
  final FeedRepository repository;

  GetGlobalFeedUseCase(this.repository);

  @override
  Future<Either<Failure, FeedPageEntity>> call(GetGlobalFeedParams params) {
    return repository.getGlobalFeed(cursor: params.cursor, size: params.size);
  }
}
