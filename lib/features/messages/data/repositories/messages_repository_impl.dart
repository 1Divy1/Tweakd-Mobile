import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/error/base_failures.dart';
import '../../../../core/realtime/dm_realtime_service.dart';
import '../../../../core/realtime/presence_service.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/chat_events.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_user.dart';
import '../../domain/entities/presence.dart';
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
  final PresenceService presenceService;
  final SupabaseClient supabaseClient;

  MessagesRepositoryImpl(
    this.dataSource,
    this.realtimeService,
    this.presenceService,
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
        // The REST payload's peer_online is a leftover of the Spring presence
        // that this build replaced — online state comes from the presence
        // channel now, and is applied on top here.
        final online = presenceService.onlineUserIds;
        final conversations = [
          for (final row in page.items)
            row.toEntity(myId, isPeerOnline: online.contains(row.peer.id)),
        ];
        return InboxEntity(
          activeNow: [
            for (final conversation in conversations)
              if (conversation.user.isOnline) conversation.user,
          ],
          conversations: conversations,
          nextCursor: page.nextCursor,
        );
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

  @override
  Stream<ChatIncomingEvent> chatEvents(String conversationId) async* {
    await for (final event in realtimeService.events) {
      final myId = _myId;
      switch (event) {
        case DmMessageCreatedEvent(:final message)
            when event.conversationId == conversationId:
          final entity = _decodePushedMessage(message);
          if (entity != null) yield ChatMessageArrived(entity);
        case DmMessageDeletedEvent(:final messageId)
            when event.conversationId == conversationId:
          yield ChatMessageDeleted(messageId);
        case DmConversationReadEvent(:final userId, :final lastReadMessageId)
            when event.conversationId == conversationId &&
                userId != myId &&
                lastReadMessageId != null:
          yield ChatMessagesSeen(upToMessageId: lastReadMessageId);
        case DmTypingEvent(:final userId, :final isTyping)
            when event.conversationId == conversationId && userId != myId:
          yield ChatPartnerTyping(isTyping);
        default:
          break;
      }
    }
  }

  @override
  Stream<InboxMessageEvent> inboxMessageEvents() async* {
    await for (final event in realtimeService.events) {
      if (event is DmMessageCreatedEvent) {
        final entity = _decodePushedMessage(event.message);
        if (entity != null) {
          yield InboxMessageEvent(
            conversationId: event.conversationId,
            message: entity,
          );
        }
      }
    }
  }

  @override
  Future<Either<Failure, List<MessageUserEntity>>> getComposeSuggestions(
    String query,
  ) =>
      _run('getComposeSuggestions', () async {
        final peers = await dataSource.searchUsers(query);
        final myId = _myId;
        final online = presenceService.onlineUserIds;
        return [
          for (final peer in peers)
            if (peer.id != myId)
              peer.toEntity(isOnline: online.contains(peer.id)),
        ];
      });

  @override
  List<PresenceEntity> getPresence(List<String> userIds) {
    final online = presenceService.onlineUserIds;
    return [
      for (final userId in userIds)
        PresenceEntity(userId: userId, online: online.contains(userId)),
    ];
  }

  @override
  Stream<PresenceEntity> presenceUpdates() => presenceService.updates.map(
        (update) => PresenceEntity(
          userId: update.userId,
          online: update.online,
        ),
      );
}
