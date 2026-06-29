import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post_pages.dart';
import '../repositories/posts_repository.dart';

class GetPostLikersParams {
  final String postId;
  final String? cursor;
  final int size;
  const GetPostLikersParams({
    required this.postId,
    this.cursor,
    this.size = 20,
  });
}

@lazySingleton
class GetPostLikersUseCase
    implements UseCase<LikerPageEntity, GetPostLikersParams> {
  final PostsRepository repository;

  GetPostLikersUseCase(this.repository);

  @override
  Future<Either<Failure, LikerPageEntity>> call(GetPostLikersParams params) {
    return repository.getLikers(
      params.postId,
      cursor: params.cursor,
      size: params.size,
    );
  }
}
