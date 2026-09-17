import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/posts_repository.dart';
import 'post_like.dart';

/// Reposts a post to the viewer's followers. Idempotent; nothing of the
/// viewer's own is attached.
@lazySingleton
class RepostPostUseCase implements UseCase<void, PostIdParams> {
  final PostsRepository repository;

  RepostPostUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(PostIdParams params) {
    return repository.repostPost(params.postId);
  }
}

/// Undoes the viewer's repost of a post. Idempotent.
@lazySingleton
class UnrepostPostUseCase implements UseCase<void, PostIdParams> {
  final PostsRepository repository;

  UnrepostPostUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(PostIdParams params) {
    return repository.unrepostPost(params.postId);
  }
}
