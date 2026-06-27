import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post.dart';
import '../repositories/posts_repository.dart';

class SaveImageKeysParams {
  final String postId;
  final List<String> keys;
  const SaveImageKeysParams({required this.postId, required this.keys});
}

@lazySingleton
class SaveImageKeysUseCase implements UseCase<PostEntity, SaveImageKeysParams> {
  final PostsRepository repository;

  SaveImageKeysUseCase(this.repository);

  @override
  Future<Either<Failure, PostEntity>> call(SaveImageKeysParams params) {
    return repository.saveImageKeys(params.postId, params.keys);
  }
}
