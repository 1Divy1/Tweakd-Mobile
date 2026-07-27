import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/forum_topic.dart';
import '../repositories/forums_repository.dart';

/// The topic catalog: a flat list ordered by `sortOrder`, used for the hub
/// refine chips and the composer's topic tags.
@lazySingleton
class GetForumTopicsUseCase
    implements UseCase<List<ForumTopicEntity>, NoParams> {
  final ForumsRepository repository;

  GetForumTopicsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ForumTopicEntity>>> call(NoParams params) {
    return repository.getTopics();
  }
}
