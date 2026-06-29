import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/posts_repository.dart';

class SharePostParams {
  final String postId;

  /// Non-blank content quote-shares; null/blank does a plain share.
  final String? content;
  const SharePostParams({required this.postId, this.content});
}

@lazySingleton
class SharePostUseCase implements UseCase<void, SharePostParams> {
  final PostsRepository repository;

  SharePostUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SharePostParams params) {
    return repository.sharePost(params.postId, content: params.content);
  }
}
