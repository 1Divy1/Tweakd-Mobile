import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post.dart';
import '../entities/post_params.dart';
import '../repositories/posts_repository.dart';

@lazySingleton
class CreatePostUseCase implements UseCase<PostEntity, CreatePostParams> {
  final PostsRepository repository;

  CreatePostUseCase(this.repository);

  @override
  Future<Either<Failure, PostEntity>> call(CreatePostParams params) {
    return repository.createPost(params);
  }
}
