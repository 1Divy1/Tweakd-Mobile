import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/forum_pages.dart';
import '../repositories/forums_repository.dart';

/// Save/unsave are idempotent bookmark toggles keyed by thread id.

@lazySingleton
class SaveForumThreadUseCase implements UseCase<void, String> {
  final ForumsRepository repository;

  SaveForumThreadUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String threadId) {
    return repository.saveThread(threadId);
  }
}

@lazySingleton
class UnsaveForumThreadUseCase implements UseCase<void, String> {
  final ForumsRepository repository;

  UnsaveForumThreadUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String threadId) {
    return repository.unsaveThread(threadId);
  }
}

class GetSavedThreadsParams {
  final String? cursor;
  final int size;

  const GetSavedThreadsParams({this.cursor, this.size = 20});
}

/// The viewer's saved threads, newest-save-first.
@lazySingleton
class GetSavedForumThreadsUseCase
    implements UseCase<ForumThreadPageEntity, GetSavedThreadsParams> {
  final ForumsRepository repository;

  GetSavedForumThreadsUseCase(this.repository);

  @override
  Future<Either<Failure, ForumThreadPageEntity>> call(
      GetSavedThreadsParams params) {
    return repository.getSavedThreads(cursor: params.cursor, size: params.size);
  }
}
