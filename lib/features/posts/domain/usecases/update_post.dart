import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post.dart';
import '../entities/post_params.dart';
import '../repositories/posts_repository.dart';

class UpdatePostUseCaseParams {
  final String postId;
  final UpdatePostParams params;
  const UpdatePostUseCaseParams({required this.postId, required this.params});
}

@lazySingleton
class UpdatePostUseCase
    implements UseCase<PostEntity, UpdatePostUseCaseParams> {
  final PostsRepository repository;

  UpdatePostUseCase(this.repository);

  @override
  Future<Either<Failure, PostEntity>> call(UpdatePostUseCaseParams params) {
    return repository.updatePost(params.postId, params.params);
  }
}
