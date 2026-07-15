import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/conversation.dart';
import '../repositories/messages_repository.dart';

@lazySingleton
class GetInboxUseCase implements UseCase<InboxEntity, NoParams> {
  final MessagesRepository repository;

  GetInboxUseCase(this.repository);

  @override
  Future<Either<Failure, InboxEntity>> call(NoParams params) =>
      repository.getInbox();
}
