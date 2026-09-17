import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tweakd/core/error/base_failures.dart';
import 'package:tweakd/core/realtime/dm_realtime_service.dart';
import 'package:tweakd/features/messages/data/datasources/messages_data_source.dart';
import 'package:tweakd/features/messages/data/repositories/messages_repository_impl.dart';
import 'package:tweakd/features/messages/domain/entities/chat.dart';
import 'package:tweakd/features/messages/domain/entities/chat_events.dart';
import 'package:tweakd/features/messages/domain/entities/conversation.dart';
import 'package:tweakd/features/messages/domain/entities/message.dart';
import 'package:tweakd/features/messages/domain/entities/message_user.dart';
import 'package:tweakd/features/messages/domain/repositories/messages_repository.dart';
import 'package:tweakd/features/messages/domain/usecases/get_conversation_peer.dart';
import 'package:tweakd/features/messages/domain/usecases/get_messages.dart';
import 'package:tweakd/features/messages/domain/usecases/message_actions.dart';
import 'package:tweakd/features/messages/domain/usecases/send_message.dart';
import 'package:tweakd/features/messages/domain/usecases/watch_chat.dart';
import 'package:tweakd/features/messages/presentation/bloc/chat/bloc.dart';
import 'package:tweakd/features/messages/presentation/bloc/chat/event.dart';
import 'package:tweakd/features/messages/presentation/bloc/chat/state.dart';

class _FakeRealtime implements DmRealtimeService {
  final controller = StreamController<DmRealtimeEvent>.broadcast();
  int holders = 0;

  @override
  Stream<DmRealtimeEvent> get events => controller.stream;

  @override
  void retain() => holders++;

  @override
  Future<void> release() async => holders--;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _UnusedDataSource implements MessagesDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

/// Serves pages in order and records mark-read calls; the live stream is a
/// controller the test drives.
class _FakeRepository implements MessagesRepository {
  final pages = <MessagesPageEntity>[];
  final live = StreamController<ChatIncomingEvent>.broadcast();
  final markedRead = <String>[];

  @override
  Future<Either<Failure, MessagesPageEntity>> getMessages(
    String conversationId, {
    String? cursor,
  }) async =>
      Right(pages.removeAt(0));

  @override
  Future<Either<Failure, void>> markConversationRead(
    String conversationId, {
    required String peerId,
  }) async {
    markedRead.add(conversationId);
    return const Right(null);
  }

  @override
  Stream<ChatIncomingEvent> chatEvents(String conversationId) => live.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

MessageEntity _msg(String id, int minute, {bool mine = false}) => MessageEntity(
      id: id,
      isMine: mine,
      text: id,
      sentAt: DateTime(2026, 9, 17, 12, minute),
    );

const _peer = MessageUserEntity(id: 'peer', username: 'peer');

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  group('live streams hold the DM topic', () {
    late _FakeRealtime realtime;
    late MessagesRepositoryImpl repository;

    setUp(() {
      realtime = _FakeRealtime();
      repository = MessagesRepositoryImpl(
        _UnusedDataSource(),
        realtime,
        SupabaseClient('http://localhost', 'test-key'),
      );
    });

    test('chat stream retains on listen and releases on cancel', () async {
      expect(realtime.holders, 0);
      final sub = repository.chatEvents('c1').listen((_) {});
      await _settle();
      expect(realtime.holders, 1);

      await sub.cancel();
      expect(realtime.holders, 0);
    });

    test('inbox and chat together hold it twice', () async {
      final inbox = repository.inboxEvents().listen((_) {});
      final chat = repository.chatEvents('c1').listen((_) {});
      await _settle();
      expect(realtime.holders, 2);

      await chat.cancel();
      expect(realtime.holders, 1);
      await inbox.cancel();
      expect(realtime.holders, 0);
    });

    test('a (re)subscribe reaches both streams as a connected event', () async {
      final chatEvents = <ChatIncomingEvent>[];
      final inboxEvents = <InboxLiveEvent>[];
      final chat = repository.chatEvents('c1').listen(chatEvents.add);
      final inbox = repository.inboxEvents().listen(inboxEvents.add);
      await _settle();

      realtime.controller.add(const DmConnectedEvent());
      await _settle();

      expect(chatEvents, [const ChatLiveConnected()]);
      expect(inboxEvents, [const InboxLiveConnected()]);
      await chat.cancel();
      await inbox.cancel();
    });
  });

  group('chat catch-up after the connection (re)opens', () {
    late _FakeRepository repository;
    late ChatBloc bloc;

    setUp(() {
      repository = _FakeRepository();
      bloc = ChatBloc(
        getMessages: GetMessagesUseCase(repository),
        getConversationPeer: GetConversationPeerUseCase(repository),
        sendMessage: SendMessageUseCase(repository),
        deleteMessage: DeleteMessageUseCase(repository),
        markConversationRead: MarkConversationReadUseCase(repository),
        sendTyping: SendTypingUseCase(repository),
        watchChat: WatchChatUseCase(repository),
      );
    });

    tearDown(() => bloc.close());

    Future<void> openChat(MessagesPageEntity first) async {
      repository.pages.add(first);
      bloc.add(const LoadChat(conversationId: 'c1', peer: _peer));
      await _settle();
      await _settle();
      repository.markedRead.clear();
    }

    test('merges missed messages, keeps the older cursor, marks read',
        () async {
      await openChat(MessagesPageEntity(
        messages: [_msg('m1', 1), _msg('m2', 2, mine: true)],
        nextCursor: 'older',
      ));

      repository.pages.add(MessagesPageEntity(
        messages: [_msg('m2', 2, mine: true), _msg('m3', 3)],
        nextCursor: 'page2',
      ));
      repository.live.add(const ChatLiveConnected());
      await _settle();
      await _settle();
      await _settle();

      final state = bloc.state as ChatLoaded;
      expect(state.messages.map((m) => m.id), ['m1', 'm2', 'm3']);
      expect(state.olderCursor, 'older');
      expect(repository.markedRead, ['c1']);
    });

    test('restarts from the latest page when a whole page was missed',
        () async {
      await openChat(MessagesPageEntity(messages: [_msg('m1', 1)]));

      repository.pages.add(MessagesPageEntity(
        messages: [_msg('m8', 8), _msg('m9', 9)],
        nextCursor: 'page2',
      ));
      repository.live.add(const ChatLiveConnected());
      await _settle();
      await _settle();
      await _settle();

      final state = bloc.state as ChatLoaded;
      expect(state.messages.map((m) => m.id), ['m8', 'm9']);
      expect(state.olderCursor, 'page2');
    });

    test('nothing missed: no state change, no mark-read', () async {
      await openChat(MessagesPageEntity(messages: [_msg('m1', 1)]));
      final before = bloc.state;

      repository.pages.add(MessagesPageEntity(messages: [_msg('m1', 1)]));
      repository.live.add(const ChatLiveConnected());
      await _settle();
      await _settle();
      await _settle();

      expect(bloc.state, before);
      expect(repository.markedRead, isEmpty);
    });
  });
}
