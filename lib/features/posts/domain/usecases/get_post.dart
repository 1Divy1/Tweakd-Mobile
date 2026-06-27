import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post.dart';
import '../repositories/posts_repository.dart';

class GetPostParams {
  final String postId;
  const GetPostParams({required this.postId});
}

@lazySingleton
class GetPostUseCase implements UseCase<PostEntity, GetPostParams> {
  final PostsRepository repository;

  GetPostUseCase(this.repository);

  @override
  Future<Either<Failure, PostEntity>> call(GetPostParams params) {
    return repository.getPost(params.postId);
  }
}
