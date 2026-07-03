import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/forum_pages.dart';
import '../repositories/forums_repository.dart';

class GetForumRepliesParams {
  /// Thread id for [GetThreadRepliesUseCase]; reply (post) id for
  /// [GetReplyChildrenUseCase].
  final String id;
  final String? cursor;
  final int size;

  const GetForumRepliesParams({required this.id, this.cursor, this.size = 20});
}

/// Top-level replies of a thread, oldest first.
@lazySingleton
class GetThreadRepliesUseCase
    implements UseCase<ForumReplyPageEntity, GetForumRepliesParams> {
  final ForumsRepository repository;

  GetThreadRepliesUseCase(this.repository);

  @override
  Future<Either<Failure, ForumReplyPageEntity>> call(
      GetForumRepliesParams params) {
    return repository.getThreadReplies(
      params.id,
      cursor: params.cursor,
      size: params.size,
    );
  }
}

/// One page of a reply's direct children (called on "show N replies").
@lazySingleton
class GetReplyChildrenUseCase
    implements UseCase<ForumReplyPageEntity, GetForumRepliesParams> {
  final ForumsRepository repository;

  GetReplyChildrenUseCase(this.repository);

  @override
  Future<Either<Failure, ForumReplyPageEntity>> call(
      GetForumRepliesParams params) {
    return repository.getReplyChildren(
      params.id,
      cursor: params.cursor,
      size: params.size,
    );
  }
}
