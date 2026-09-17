import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post_pages.dart';
import '../repositories/posts_repository.dart';
import 'get_posts_by_username.dart';

/// The posts a user reposted, newest repost first — a profile's Reposts tab.
/// Takes the same params as [GetPostsByUsernameUseCase].
@lazySingleton
class GetRepostsByUsernameUseCase
    implements UseCase<PostPageEntity, GetPostsByUsernameParams> {
  final PostsRepository repository;

  GetRepostsByUsernameUseCase(this.repository);

  @override
  Future<Either<Failure, PostPageEntity>> call(
    GetPostsByUsernameParams params,
  ) {
    return repository.getRepostsByUsername(
      params.username,
      cursor: params.cursor,
      size: params.size,
    );
  }
}
