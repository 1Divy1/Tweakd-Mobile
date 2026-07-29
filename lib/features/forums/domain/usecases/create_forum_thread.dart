import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/forum_thread.dart';
import '../repositories/forums_repository.dart';

class CreateForumThreadParams {
  final String title;
  final String brandId;
  final String content;
  final String? modelId;
  final List<String> topicIds;

  /// Profile ids tagged in the OP (max 30, deduplicated server-side).
  final List<String> taggedPeople;

  /// Car ids tagged in the OP (max 30). Every tagged car's owner must also be
  /// in [taggedPeople] — the author's own cars are exempt.
  final List<String> taggedCars;

  const CreateForumThreadParams({
    required this.title,
    required this.brandId,
    required this.content,
    this.modelId,
    this.topicIds = const [],
    this.taggedPeople = const [],
    this.taggedCars = const [],
  });
}

@lazySingleton
class CreateForumThreadUseCase
    implements UseCase<ForumThreadDetailEntity, CreateForumThreadParams> {
  final ForumsRepository repository;

  CreateForumThreadUseCase(this.repository);

  @override
  Future<Either<Failure, ForumThreadDetailEntity>> call(
    CreateForumThreadParams params,
  ) {
    return repository.createThread(
      title: params.title,
      content: params.content,
      modelId: params.modelId,
      brandId: params.brandId,
      topicIds: params.topicIds,
      taggedPeople: params.taggedPeople,
      taggedCars: params.taggedCars,
    );
  }
}
