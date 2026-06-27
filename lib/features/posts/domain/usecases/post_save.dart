import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/posts_repository.dart';
import 'post_like.dart';

@lazySingleton
class SavePostUseCase implements UseCase<void, PostIdParams> {
  final PostsRepository repository;

  SavePostUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(PostIdParams params) {
    return repository.savePost(params.postId);
  }
}

@lazySingleton
class UnsavePostUseCase implements UseCase<void, PostIdParams> {
  final PostsRepository repository;

  UnsavePostUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(PostIdParams params) {
    return repository.unsavePost(params.postId);
  }
}
