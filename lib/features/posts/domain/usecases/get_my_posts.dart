import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post_pages.dart';
import '../repositories/posts_repository.dart';

class GetMyPostsParams {
  final String? cursor;
  final int size;
  const GetMyPostsParams({this.cursor, this.size = 20});
}

@lazySingleton
class GetMyPostsUseCase implements UseCase<PostPageEntity, GetMyPostsParams> {
  final PostsRepository repository;

  GetMyPostsUseCase(this.repository);

  @override
  Future<Either<Failure, PostPageEntity>> call(GetMyPostsParams params) {
    return repository.getMyPosts(cursor: params.cursor, size: params.size);
  }
}
