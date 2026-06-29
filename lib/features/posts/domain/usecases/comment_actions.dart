import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/posts_repository.dart';

class CommentRefParams {
  final String postId;
  final String commentId;
  const CommentRefParams({required this.postId, required this.commentId});
}

@lazySingleton
class DeleteCommentUseCase implements UseCase<void, CommentRefParams> {
  final PostsRepository repository;

  DeleteCommentUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CommentRefParams params) {
    return repository.deleteComment(params.postId, params.commentId);
  }
}

@lazySingleton
class LikeCommentUseCase implements UseCase<void, CommentRefParams> {
  final PostsRepository repository;

  LikeCommentUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CommentRefParams params) {
    return repository.likeComment(params.postId, params.commentId);
  }
}

@lazySingleton
class UnlikeCommentUseCase implements UseCase<void, CommentRefParams> {
  final PostsRepository repository;

  UnlikeCommentUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CommentRefParams params) {
    return repository.unlikeComment(params.postId, params.commentId);
  }
}
