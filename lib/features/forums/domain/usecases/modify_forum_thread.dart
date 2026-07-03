import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/forum_thread.dart';
import '../repositories/forums_repository.dart';

class EditForumThreadParams {
  final String threadId;

  /// The new OP body; an empty string clears it.
  final String content;

  const EditForumThreadParams({required this.threadId, required this.content});
}

/// Author-only edit of the OP body (title/topics/car are immutable).
@lazySingleton
class EditForumThreadUseCase
    implements UseCase<ForumThreadDetailEntity, EditForumThreadParams> {
  final ForumsRepository repository;

  EditForumThreadUseCase(this.repository);

  @override
  Future<Either<Failure, ForumThreadDetailEntity>> call(
      EditForumThreadParams params) {
    return repository.editThread(params.threadId, content: params.content);
  }
}

/// Author-only. A thread with replies is anonymized (stays visible as
/// "[deleted]"); one without replies is removed entirely.
@lazySingleton
class DeleteForumThreadUseCase implements UseCase<void, String> {
  final ForumsRepository repository;

  DeleteForumThreadUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String threadId) {
    return repository.deleteThread(threadId);
  }
}
