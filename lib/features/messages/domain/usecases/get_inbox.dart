import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/conversation.dart';
import '../repositories/messages_repository.dart';

/// One page of the inbox. Params is the keyset cursor — null for page 1.
@lazySingleton
class GetInboxUseCase implements UseCase<InboxEntity, String?> {
  final MessagesRepository repository;

  GetInboxUseCase(this.repository);

  @override
  Future<Either<Failure, InboxEntity>> call(String? cursor) =>
      repository.getInbox(cursor: cursor);
}
