import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/error/base_failures.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/chat_events.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_user.dart';
import '../../domain/repositories/messages_repository.dart';
import '../datasources/messages_data_source.dart';

@LazySingleton(as: MessagesRepository)
class MessagesRepositoryImpl implements MessagesRepository {
  final MessagesDataSource dataSource;

  MessagesRepositoryImpl(this.dataSource);

  /// Shared exception → failure mapping. The mock datasource never throws the
  /// API exceptions, but the real one will — the pipeline is already in place.
  Future<Either<Failure, T>> _run<T>(
    String op,
    Future<T> Function() body,
  ) async {
    try {
      return Right(await body());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('messages $op error: $e');
      return Left(UnknownFailure('Messages request failed: $op.'));
    }
  }

  @override
  Future<Either<Failure, InboxEntity>> getInbox() =>
      _run('getInbox', dataSource.getInbox);

  @override
  Future<Either<Failure, ChatEntity>> getChat(String conversationId) =>
      _run('getChat', () => dataSource.getChat(conversationId));

  @override
  Future<Either<Failure, MessageEntity>> sendMessage(
    String conversationId,
    String text,
  ) =>
      _run('sendMessage', () => dataSource.sendMessage(conversationId, text));

  @override
  Stream<ChatIncomingEvent> chatEvents(String conversationId) =>
      dataSource.chatEvents(conversationId);

  @override
  Future<Either<Failure, List<MessageUserEntity>>> getComposeSuggestions(
    String query,
  ) =>
      _run('getComposeSuggestions',
          () => dataSource.getComposeSuggestions(query));

  @override
  Future<Either<Failure, String>> startConversation(String userId) =>
      _run('startConversation', () => dataSource.startConversation(userId));
}
