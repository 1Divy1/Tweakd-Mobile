import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post_pages.dart';
import '../repositories/posts_repository.dart';

class GetCommentRepliesParams {
  final String postId;
  final String commentId;
  final String? cursor;
  final int size;
  const GetCommentRepliesParams({
    required this.postId,
    required this.commentId,
    this.cursor,
    this.size = 20,
  });
}

@lazySingleton
class GetCommentRepliesUseCase
    implements UseCase<CommentPageEntity, GetCommentRepliesParams> {
  final PostsRepository repository;

  GetCommentRepliesUseCase(this.repository);

  @override
  Future<Either<Failure, CommentPageEntity>> call(
    GetCommentRepliesParams params,
  ) {
    return repository.getReplies(
      params.postId,
      params.commentId,
      cursor: params.cursor,
      size: params.size,
    );
  }
}
