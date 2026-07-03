import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/forum_thread.dart';
import '../repositories/forums_repository.dart';

class CreateForumThreadParams {
  final String title;
  final String? content;

  /// When set, the brand is derived by the backend; [brandId] is used only
  /// when [modelId] is null.
  final String? modelId;
  final String? brandId;
  final List<String> topicIds;

  const CreateForumThreadParams({
    required this.title,
    this.content,
    this.modelId,
    this.brandId,
    this.topicIds = const [],
  });
}

@lazySingleton
class CreateForumThreadUseCase
    implements UseCase<ForumThreadDetailEntity, CreateForumThreadParams> {
  final ForumsRepository repository;

  CreateForumThreadUseCase(this.repository);

  @override
  Future<Either<Failure, ForumThreadDetailEntity>> call(
      CreateForumThreadParams params) {
    return repository.createThread(
      title: params.title,
      content: params.content,
      modelId: params.modelId,
      brandId: params.modelId == null ? params.brandId : null,
      topicIds: params.topicIds,
    );
  }
}
