import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/forum_topic.dart';
import '../repositories/forums_repository.dart';

@lazySingleton
class GetForumTopicsUseCase
    implements UseCase<List<ForumTopicGroupEntity>, NoParams> {
  final ForumsRepository repository;

  GetForumTopicsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ForumTopicGroupEntity>>> call(NoParams params) {
    return repository.getTopics();
  }
}
