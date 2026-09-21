import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post.dart';
import '../entities/post_params.dart';
import '../repositories/posts_repository.dart';

/// Shares one of the viewer's build-log modifications to the feed.
@lazySingleton
class ShareModificationUseCase
    implements UseCase<PostEntity, ShareModificationParams> {
  final PostsRepository repository;

  ShareModificationUseCase(this.repository);

  @override
  Future<Either<Failure, PostEntity>> call(ShareModificationParams params) {
    return repository.shareModification(params);
  }
}
