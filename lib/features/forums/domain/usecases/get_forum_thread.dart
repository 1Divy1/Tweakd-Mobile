import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/forum_thread.dart';
import '../repositories/forums_repository.dart';

@lazySingleton
class GetForumThreadUseCase
    implements UseCase<ForumThreadDetailEntity, String> {
  final ForumsRepository repository;

  GetForumThreadUseCase(this.repository);

  @override
  Future<Either<Failure, ForumThreadDetailEntity>> call(String threadId) {
    return repository.getThread(threadId);
  }
}
