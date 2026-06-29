import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post_upload.dart';
import '../repositories/posts_repository.dart';

class GetImageUploadUrlsParams {
  final String postId;
  final int count;
  const GetImageUploadUrlsParams({required this.postId, required this.count});
}

@lazySingleton
class GetImageUploadUrlsUseCase
    implements UseCase<PostUploadUrlsResult, GetImageUploadUrlsParams> {
  final PostsRepository repository;

  GetImageUploadUrlsUseCase(this.repository);

  @override
  Future<Either<Failure, PostUploadUrlsResult>> call(
    GetImageUploadUrlsParams params,
  ) {
    return repository.getImageUploadUrls(params.postId, params.count);
  }
}
