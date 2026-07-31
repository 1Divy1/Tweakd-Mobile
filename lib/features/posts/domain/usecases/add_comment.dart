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

  /// Profile ids tagged in the comment.
  final List<String> taggedPeople;

  /// Car ids tagged in the comment; each car's owner must be in [taggedPeople]
  /// unless the car belongs to the commenter.
  final List<String> taggedCars;

  const AddCommentParams({
    required this.postId,
    required this.content,
    this.parentCommentId,
    this.taggedPeople = const [],
    this.taggedCars = const [],
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
      taggedPeople: params.taggedPeople,
      taggedCars: params.taggedCars,
    );
  }
}
