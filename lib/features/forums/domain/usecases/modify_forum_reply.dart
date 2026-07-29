import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/forum_reply.dart';
import '../repositories/forums_repository.dart';

class EditForumReplyParams {
  final String postId;
  final String content;

  /// Replace-all tag sets; null leaves that set untouched, empty clears it.
  final List<String>? taggedPeople;
  final List<String>? taggedCars;

  const EditForumReplyParams({
    required this.postId,
    required this.content,
    this.taggedPeople,
    this.taggedCars,
  });
}

@lazySingleton
class EditForumReplyUseCase
    implements UseCase<ForumReplyEntity, EditForumReplyParams> {
  final ForumsRepository repository;

  EditForumReplyUseCase(this.repository);

  @override
  Future<Either<Failure, ForumReplyEntity>> call(EditForumReplyParams params) {
    return repository.editReply(
      params.postId,
      content: params.content,
      taggedPeople: params.taggedPeople,
      taggedCars: params.taggedCars,
    );
  }
}

/// Author-only. A reply with children becomes a "[deleted]" placeholder;
/// a childless one is removed entirely.
@lazySingleton
class DeleteForumReplyUseCase implements UseCase<void, String> {
  final ForumsRepository repository;

  DeleteForumReplyUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String postId) {
    return repository.deleteReply(postId);
  }
}
