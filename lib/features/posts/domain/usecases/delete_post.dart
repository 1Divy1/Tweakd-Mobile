import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/posts_repository.dart';

class DeletePostParams {
  final String postId;
  const DeletePostParams({required this.postId});
}

@lazySingleton
class DeletePostUseCase implements UseCase<void, DeletePostParams> {
  final PostsRepository repository;

  DeletePostUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeletePostParams params) {
    return repository.deletePost(params.postId);
  }
}
