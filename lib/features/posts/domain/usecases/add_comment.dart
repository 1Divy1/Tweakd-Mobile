import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post_comment.dart';
import '../repositories/posts_repository.dart';

class AddCommentParams {
  final String postId;
  final String content;

  /// Null for a root comment; set to reply to another comment on the same post.
  final String? parentCommentId;

  const AddCommentParams({
    required this.postId,
    required this.content,
    this.parentCommentId,
  });
}

@lazySingleton
class AddCommentUseCase implements UseCase<PostCommentEntity, AddCommentParams> {
  final PostsRepository repository;

  AddCommentUseCase(this.repository);

  @override
  Future<Either<Failure, PostCommentEntity>> call(AddCommentParams params) {
    return repository.addComment(
      params.postId,
      content: params.content,
      parentCommentId: params.parentCommentId,
    );
  }
}
