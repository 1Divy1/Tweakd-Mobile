import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post_pages.dart';
import '../repositories/posts_repository.dart';

class GetPostCommentsParams {
  final String postId;
  final String? cursor;
  final int size;
  const GetPostCommentsParams({
    required this.postId,
    this.cursor,
    this.size = 20,
  });
}

@lazySingleton
class GetPostCommentsUseCase
    implements UseCase<CommentPageEntity, GetPostCommentsParams> {
  final PostsRepository repository;

  GetPostCommentsUseCase(this.repository);

  @override
  Future<Either<Failure, CommentPageEntity>> call(
    GetPostCommentsParams params,
  ) {
    return repository.getComments(
      params.postId,
      cursor: params.cursor,
      size: params.size,
    );
  }
}
