import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post.dart';
import '../entities/post_params.dart';
import '../repositories/posts_repository.dart';

/// Shares one of the viewer's participant cards to the feed.
@lazySingleton
class ShareParticipantCardUseCase
    implements UseCase<PostEntity, ShareParticipantCardParams> {
  final PostsRepository repository;

  ShareParticipantCardUseCase(this.repository);

  @override
  Future<Either<Failure, PostEntity>> call(ShareParticipantCardParams params) {
    return repository.shareParticipantCard(params);
  }
}
