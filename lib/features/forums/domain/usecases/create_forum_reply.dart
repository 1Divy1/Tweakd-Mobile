import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/forum_reply.dart';
import '../repositories/forums_repository.dart';

class CreateForumReplyParams {
  final String threadId;
  final String content;

  /// Null = a top-level reply; otherwise the parent reply's id (must belong
  /// to the same thread).
  final String? parentPostId;

  const CreateForumReplyParams({
    required this.threadId,
    required this.content,
    this.parentPostId,
  });
}

@lazySingleton
class CreateForumReplyUseCase
    implements UseCase<ForumReplyEntity, CreateForumReplyParams> {
  final ForumsRepository repository;

  CreateForumReplyUseCase(this.repository);

  @override
  Future<Either<Failure, ForumReplyEntity>> call(
      CreateForumReplyParams params) {
    return repository.createReply(
      params.threadId,
      content: params.content,
      parentPostId: params.parentPostId,
    );
  }
}
