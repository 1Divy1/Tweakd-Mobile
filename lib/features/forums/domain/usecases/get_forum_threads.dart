import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/forum_filter.dart';
import '../entities/forum_pages.dart';
import '../entities/forum_thread.dart';
import '../repositories/forums_repository.dart';

class GetForumThreadsParams {
  /// Null or empty = the global forums feed.
  final ForumFilter? filter;
  final ForumThreadSort sort;
  final String? cursor;
  final int size;

  const GetForumThreadsParams({
    this.filter,
    this.sort = ForumThreadSort.hot,
    this.cursor,
    this.size = 20,
  });
}

@lazySingleton
class GetForumThreadsUseCase
    implements UseCase<ForumThreadPageEntity, GetForumThreadsParams> {
  final ForumsRepository repository;

  GetForumThreadsUseCase(this.repository);

  @override
  Future<Either<Failure, ForumThreadPageEntity>> call(
      GetForumThreadsParams params) {
    return repository.getThreads(
      filter: params.filter,
      sort: params.sort,
      cursor: params.cursor,
      size: params.size,
    );
  }
}
