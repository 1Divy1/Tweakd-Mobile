import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post_pages.dart';
import '../repositories/posts_repository.dart';

class GetSavedPostsParams {
  final String? cursor;
  final int size;
  const GetSavedPostsParams({this.cursor, this.size = 20});
}

@lazySingleton
class GetSavedPostsUseCase
    implements UseCase<PostPageEntity, GetSavedPostsParams> {
  final PostsRepository repository;

  GetSavedPostsUseCase(this.repository);

  @override
  Future<Either<Failure, PostPageEntity>> call(GetSavedPostsParams params) {
    return repository.getSavedPosts(cursor: params.cursor, size: params.size);
  }
}
