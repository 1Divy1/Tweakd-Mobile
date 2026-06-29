import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post_pages.dart';
import '../repositories/posts_repository.dart';

class GetPostsByUsernameParams {
  final String username;
  final String? cursor;
  final int size;
  const GetPostsByUsernameParams({
    required this.username,
    this.cursor,
    this.size = 20,
  });
}

@lazySingleton
class GetPostsByUsernameUseCase
    implements UseCase<PostPageEntity, GetPostsByUsernameParams> {
  final PostsRepository repository;

  GetPostsByUsernameUseCase(this.repository);

  @override
  Future<Either<Failure, PostPageEntity>> call(
    GetPostsByUsernameParams params,
  ) {
    return repository.getPostsByUsername(
      params.username,
      cursor: params.cursor,
      size: params.size,
    );
  }
}
