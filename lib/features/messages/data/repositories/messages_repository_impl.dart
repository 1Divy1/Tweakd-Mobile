import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/error/base_failures.dart';
import '../../../../core/realtime/dm_realtime_service.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/chat_events.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_user.dart';
import '../../domain/repositories/messages_repository.dart';
import '../datasources/messages_data_source.dart';
import '../models/dm_models.dart';

/// Reads come from Spring REST; sending goes through the Supabase
/// `dm_send_message` RPC; every live update is a Supabase Broadcast this
/// client publishes right after its own write succeeds.
@LazySingleton(as: MessagesRepository)
class MessagesRepositoryImpl implements MessagesRepository {
  final MessagesDataSource dataSource;
  final DmRealtimeService realtimeService;
  final SupabaseClient supabaseClient;

  MessagesRepositoryImpl(
    this.dataSource,
    this.realtimeService,
    this.supabaseClient,
  );

  /// The viewer's id — `sender_id == _myId` decides [MessageEntity.isMine].
  String get _myId => supabaseClient.auth.currentUser?.id ?? '';

  /// Shared exception → failure mapping.
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
  Future<Either<Failure, InboxEntity>> getInbox({String? cursor}) =>
      _run('getInbox', () async {
        final page = await dataSource.getConversations(cursor: cursor);
        final myId = _myId;
        return InboxEntity(
          conversations: [
            for (final row in page.items) row.toEntity(myId),
          ],
          nextCursor: page.nextCursor,
        );
      });

  @override
  Future<Either<Failure, MessageUserEntity>> getConversationPeer(
    String conversationId,
  ) =>
      _run('getConversationPeer', () async {
        final conversation = await dataSource.getConversation(conversationId);
        return conversation.peer.toEntity();
      });

  @override
  Future<Either<Failure, MessagesPageEntity>> getMessages(
    String conversationId, {
    String? cursor,
  }) =>
      _run('getMessages', () async {
        final page =
            await dataSource.getMessages(conversationId, cursor: cursor);
        final myId = _myId;
        return MessagesPageEntity(
          // Wire is newest-first; the app stores oldest-first.
          messages: [
            for (final model in page.items.reversed) model.toEntity(myId),
          ],
          nextCursor: page.nextCursor,
          peerLastReadMessageId: page.peerLastReadMessageId,
        );
      });

  @override
  Future<Either<Failure, SentMessageEntity>> sendMessage(
    String recipientId,
    String text, {
    List<DmTaggedCarEntity> taggedCars = const [],
  }) =>
      _run('sendMessage', () async {
        final cars = [
          for (final car in taggedCars) DmTaggedCarModel.fromEntity(car),
        ];
        final model = await dataSource.sendMessage(
          recipientId: recipientId,
          content: text,
          taggedCars: cars,
        );
        // Hand the peer the fully hydrated message: their client renders it
        // as-is, car chips included. The durable copy is already in the
        // database and comes back from Spring on any history load.
        realtimeService.broadcastMessageCreated(
          peerId: recipientId,
          conversationId: model.conversationId,
          message: model.toJson(),
        );
        return SentMessageEntity(
          conversationId: model.conversationId,
          message: model.toEntity(_myId),
        );
      });

  @override
  Future<Either<Failure, void>> deleteMessage(
    String messageId, {
    required String conversationId,
    required String peerId,
  }) =>
      _run('deleteMessage', () async {
        await dataSource.deleteMessage(messageId);
        realtimeService.broadcastMessageDeleted(
          peerId: peerId,
          conversationId: conversationId,
          messageId: messageId,
        );
      });

  @override
  Future<Either<Failure, void>> hideConversation(String conversationId) =>
      _run('hideConversation',
          () => dataSource.hideConversation(conversationId));

  @override
  Future<Either<Failure, void>> markConversationRead(
    String conversationId, {
    required String peerId,
  }) =>
      _run('markConversationRead', () async {
        final lastReadMessageId = await dataSource.markRead(conversationId);
        realtimeService.broadcastConversationRead(
          peerId: peerId,
          conversationId: conversationId,
          lastReadMessageId: lastReadMessageId,
        );
      });

  @override
  Future<Either<Failure, int>> getUnreadCount() =>
      _run('getUnreadCount', () => dataSource.getUnreadCount());

  @override
  void sendTyping(
    String conversationId,
    bool isTyping, {
    required String peerId,
  }) =>
      realtimeService.sendTyping(
        peerId: peerId,
        conversationId: conversationId,
        isTyping: isTyping,
      );

  /// Decodes a broadcast message payload; null (skip) on malformed input so
  /// one bad event can never tear down a live stream subscription.
  MessageEntity? _decodePushedMessage(Map<String, dynamic> json) {
    try {
      return DmMessageModel.fromJson(json).toEntity(_myId);
    } catch (e) {
      debugPrint('messages: dropped malformed pushed message: $e');
      return null;
    }
  }

  /// The viewer's live events mapped through [toEvent] (null = skip), with
  /// the DM topic held for exactly as long as the stream has a listener.
  ///
  /// Deliberately not an `async*` generator: cancelling one that is suspended
  /// in `await for` only takes effect at its next `yield`, so on a quiet topic
  /// the release would never run and the socket would stay open. The retain
  /// happens before `events` is listened to, but the join is asynchronous, so
  /// its [DmConnectedEvent] is never missed.
  Stream<T> _whileHeld<T>(T? Function(DmRealtimeEvent event) toEvent) {
    StreamSubscription<DmRealtimeEvent>? source;
    late final StreamController<T> controller;
    controller = StreamController<T>(
      onListen: () {
        realtimeService.retain();
        source = realtimeService.events.listen((event) {
          final mapped = toEvent(event);
          if (mapped != null) controller.add(mapped);
        });
      },
      onCancel: () async {
        await source?.cancel();
        await realtimeService.release();
      },
    );
    return controller.stream;
  }

  @override
  Stream<ChatIncomingEvent> chatEvents(String conversationId) =>
      _whileHeld((event) {
        final myId = _myId;
        return switch (event) {
          DmConnectedEvent() => const ChatLiveConnected(),
          DmMessageCreatedEvent(:final message)
              when event.conversationId == conversationId =>
            switch (_decodePushedMessage(message)) {
              final entity? => ChatMessageArrived(entity),
              null => null,
            },
          DmMessageDeletedEvent(:final messageId)
              when event.conversationId == conversationId =>
            ChatMessageDeleted(messageId),
          DmConversationReadEvent(:final userId, :final lastReadMessageId)
              when event.conversationId == conversationId &&
                  userId != myId &&
                  lastReadMessageId != null =>
            ChatMessagesSeen(upToMessageId: lastReadMessageId),
          DmTypingEvent(:final userId, :final isTyping)
              when event.conversationId == conversationId && userId != myId =>
            ChatPartnerTyping(isTyping),
          _ => null,
        };
      });

  @override
  Stream<InboxLiveEvent> inboxEvents() => _whileHeld((event) => switch (event) {
        DmConnectedEvent() => const InboxLiveConnected(),
        DmMessageCreatedEvent() =>
          switch (_decodePushedMessage(event.message)) {
            final entity? => InboxMessageEvent(
                conversationId: event.conversationId,
                message: entity,
              ),
            null => null,
          },
        _ => null,
      });

  @override
  Future<Either<Failure, List<MessageUserEntity>>> getComposeSuggestions(
    String query,
  ) =>
      _run('getComposeSuggestions', () async {
        final peers = await dataSource.searchUsers(query);
        final myId = _myId;
        return [
          for (final peer in peers)
            if (peer.id != myId) peer.toEntity(),
        ];
      });
}
