import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/forums_repository.dart';

/// Like endpoints are idempotent and race-safe.

@lazySingleton
class LikeForumThreadUseCase implements UseCase<void, String> {
  final ForumsRepository repository;

  LikeForumThreadUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String threadId) {
    return repository.likeThread(threadId);
  }
}

@lazySingleton
class UnlikeForumThreadUseCase implements UseCase<void, String> {
  final ForumsRepository repository;

  UnlikeForumThreadUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String threadId) {
    return repository.unlikeThread(threadId);
  }
}

@lazySingleton
class LikeForumReplyUseCase implements UseCase<void, String> {
  final ForumsRepository repository;

  LikeForumReplyUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String postId) {
    return repository.likeReply(postId);
  }
}

@lazySingleton
class UnlikeForumReplyUseCase implements UseCase<void, String> {
  final ForumsRepository repository;

  UnlikeForumReplyUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String postId) {
    return repository.unlikeReply(postId);
  }
}
