import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message_user.dart';
import '../repositories/messages_repository.dart';

/// Users the viewer can message from the compose sheet, filtered by [query].
@lazySingleton
class GetComposeSuggestionsUseCase
    implements UseCase<List<MessageUserEntity>, String> {
  final MessagesRepository repository;

  GetComposeSuggestionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<MessageUserEntity>>> call(String query) =>
      repository.getComposeSuggestions(query);
}

/// Opens (or creates) a conversation with a user; returns the conversation id.
@lazySingleton
class StartConversationUseCase implements UseCase<String, String> {
  final MessagesRepository repository;

  StartConversationUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(String userId) =>
      repository.startConversation(userId);
}
