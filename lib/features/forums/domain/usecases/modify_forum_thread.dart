import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/forum_thread.dart';
import '../repositories/forums_repository.dart';

class EditForumThreadParams {
  final String threadId;

  /// The new OP body. Required and non-blank — a thread always keeps a body.
  final String content;

  /// Replace-all tag sets. Null leaves that set untouched; an empty list
  /// clears it.
  final List<String>? taggedPeople;
  final List<String>? taggedCars;

  const EditForumThreadParams({
    required this.threadId,
    required this.content,
    this.taggedPeople,
    this.taggedCars,
  });
}

/// Author-only edit of the OP body and its tags (title/topics/car are
/// immutable).
@lazySingleton
class EditForumThreadUseCase
    implements UseCase<ForumThreadDetailEntity, EditForumThreadParams> {
  final ForumsRepository repository;

  EditForumThreadUseCase(this.repository);

  @override
  Future<Either<Failure, ForumThreadDetailEntity>> call(
      EditForumThreadParams params) {
    return repository.editThread(
      params.threadId,
      content: params.content,
      taggedPeople: params.taggedPeople,
      taggedCars: params.taggedCars,
    );
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
