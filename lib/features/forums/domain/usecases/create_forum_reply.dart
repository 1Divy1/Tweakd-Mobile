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

  /// Profile ids tagged in the reply (max 30).
  final List<String> taggedPeople;

  /// Car ids tagged in the reply (max 30); each car's owner must be tagged
  /// too, unless the car is the author's own.
  final List<String> taggedCars;

  const CreateForumReplyParams({
    required this.threadId,
    required this.content,
    this.parentPostId,
    this.taggedPeople = const [],
    this.taggedCars = const [],
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
      taggedPeople: params.taggedPeople,
      taggedCars: params.taggedCars,
    );
  }
}
