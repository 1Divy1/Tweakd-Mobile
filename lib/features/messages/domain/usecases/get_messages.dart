import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chat.dart';
import '../repositories/messages_repository.dart';

class GetMessagesParams extends Equatable {
  final String conversationId;

  /// Keyset cursor for older pages — null for the newest page.
  final String? cursor;

  const GetMessagesParams({required this.conversationId, this.cursor});

  @override
  List<Object?> get props => [conversationId, cursor];
}

@lazySingleton
class GetMessagesUseCase
    implements UseCase<MessagesPageEntity, GetMessagesParams> {
  final MessagesRepository repository;

  GetMessagesUseCase(this.repository);

  @override
  Future<Either<Failure, MessagesPageEntity>> call(GetMessagesParams params) =>
      repository.getMessages(params.conversationId, cursor: params.cursor);
}
