import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/posts_repository.dart';

class PostIdParams {
  final String postId;
  const PostIdParams({required this.postId});
}

@lazySingleton
class LikePostUseCase implements UseCase<void, PostIdParams> {
  final PostsRepository repository;

  LikePostUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(PostIdParams params) {
    return repository.likePost(params.postId);
  }
}

@lazySingleton
class UnlikePostUseCase implements UseCase<void, PostIdParams> {
  final PostsRepository repository;

  UnlikePostUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(PostIdParams params) {
    return repository.unlikePost(params.postId);
  }
}
