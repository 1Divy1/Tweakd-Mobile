import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../domain/entities/chat.dart';
import '../../domain/entities/chat_events.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_user.dart';

/// Contract the repository talks to. Today only [MockMessagesDataSource]
/// implements it; the real API datasource will replace that binding once the
/// backend lands (snake_case JSON models, endpoints TBD).
abstract class MessagesDataSource {
  Future<InboxEntity> getInbox();
  Future<ChatEntity> getChat(String conversationId);
  Future<MessageEntity> sendMessage(String conversationId, String text);
  Stream<ChatIncomingEvent> chatEvents(String conversationId);
  Future<List<MessageUserEntity>> getComposeSuggestions(String query);
  Future<String> startConversation(String userId);
}

/// In-memory mock with mutable state, so the UI behaves like the real thing:
/// opening a chat clears its unread count, sending appends and reorders the
/// inbox, and each send triggers a seen → typing → canned-reply choreography
/// on the [chatEvents] stream to exercise the animations.
@LazySingleton(as: MessagesDataSource)
class MockMessagesDataSource implements MessagesDataSource {
  final Map<String, MessageUserEntity> _users = {};
  final Map<String, _MockConversation> _conversations = {};
  final Map<String, StreamController<ChatIncomingEvent>> _eventControllers =
      {};
  final Map<String, List<Timer>> _replyTimers = {};
  int _idSeq = 0;
  int _replySeq = 0;

  MockMessagesDataSource() {
    _seed();
  }

  String _nextId(String prefix) => '$prefix-${++_idSeq}';

  static const _cannedReplies = [
    'Perfect. Meet at the usual spot?',
    'Haha say less 😂',
    'Send pics when you get there 📸',
    'That sounds unreal. I\'m in.',
    'Deal. First coffee round is on you though ☕️',
    'Okay now I\'m hyped for this.',
  ];

  void _seed() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime at(int hour, int minute) =>
        today.add(Duration(hours: hour, minutes: minute));

    const marcus = MessageUserEntity(
      id: 'u-marcus',
      username: 'marcus_vlox',
      isVerified: true,
      isOnline: true,
      isMutualFollow: true,
      followersCount: 4200,
    );
    const sasha = MessageUserEntity(
      id: 'u-sasha',
      username: 'torque_sasha',
      isVerified: true,
      isOnline: true,
      isMutualFollow: true,
      followersCount: 12800,
    );
    const jules = MessageUserEntity(
      id: 'u-jules',
      username: 'jdm_jules',
      isVerified: true,
      isMutualFollow: true,
      followersCount: 9300,
    );
    const kenji = MessageUserEntity(
      id: 'u-kenji',
      username: 'kenji_apex',
      isVerified: true,
      isMutualFollow: true,
      followersCount: 21500,
    );
    const leo = MessageUserEntity(
      id: 'u-leo',
      username: 'low_n_slow_leo',
      isMutualFollow: true,
      followersCount: 1800,
    );
    const rae = MessageUserEntity(
      id: 'u-rae',
      username: 'rallyrider_rae',
      isMutualFollow: true,
      followersCount: 3400,
    );
    // Compose-sheet-only users (no conversation yet).
    const valeria = MessageUserEntity(
      id: 'u-valeria',
      username: 'vroom_valeria',
      followersCount: 950,
    );
    const nico = MessageUserEntity(
      id: 'u-nico',
      username: 'noctis_nico',
      isVerified: true,
      followersCount: 7600,
    );

    for (final user in [marcus, sasha, jules, kenji, leo, rae, valeria, nico]) {
      _users[user.id] = user;
    }

    _conversations['c-marcus'] = _MockConversation(
      id: 'c-marcus',
      userId: marcus.id,
      unreadCount: 2,
      messages: [
        MessageEntity(
          id: _nextId('m'),
          isMine: false,
          text: 'Yo — you free this weekend?',
          sentAt: at(8, 10),
        ),
        MessageEntity(
          id: _nextId('m'),
          isMine: false,
          text: 'Thinking a dawn run up Col de Turini before the crowds hit 🏔',
          sentAt: at(8, 12),
        ),
        MessageEntity(
          id: _nextId('m'),
          isMine: true,
          text: 'Say less. What time are we rolling out?',
          sentAt: at(8, 13),
          isSeen: true,
        ),
        MessageEntity(
          id: _nextId('m'),
          isMine: false,
          text: '5:30 from the marina. Golden hour on the switchbacks is '
              'unreal.',
          sentAt: at(8, 14),
        ),
        MessageEntity(
          id: _nextId('m'),
          isMine: false,
          kind: MessageKind.sharedPost,
          sharedPost: const MessageSharedPostEntity(
            postId: 'post-turini',
            authorUsername: 'marcus_vlox',
            caption: 'Golden hour on the switchbacks — this is the shot I '
                'want to recreate',
          ),
          sentAt: at(8, 14),
        ),
        MessageEntity(
          id: _nextId('m'),
          isMine: true,
          text: 'That framing 🔥 count me in',
          sentAt: at(8, 15),
          isSeen: true,
        ),
        MessageEntity(
          id: _nextId('m'),
          isMine: true,
          text: 'I\'ll bring the M4, just got it detailed',
          sentAt: at(8, 15),
          isSeen: true,
        ),
        MessageEntity(
          id: _nextId('m'),
          isMine: false,
          text: 'Forecast says clear skies all morning ☀️',
          sentAt: now.subtract(const Duration(minutes: 3)),
        ),
        MessageEntity(
          id: _nextId('m'),
          isMine: false,
          text: 'Dawn run Sunday? Col de Turini before the crowds hit',
          sentAt: now.subtract(const Duration(minutes: 2)),
        ),
      ],
    );

    _conversations['c-sasha'] = _MockConversation(
      id: 'c-sasha',
      userId: sasha.id,
      messages: [
        MessageEntity(
          id: _nextId('m'),
          isMine: false,
          text: 'The marina set from Saturday is 🤌 need those files',
          sentAt: now.subtract(const Duration(minutes: 25)),
        ),
        MessageEntity(
          id: _nextId('m'),
          isMine: true,
          text: 'sending the marina shots over now, the roller is the '
              'keeper',
          sentAt: now.subtract(const Duration(minutes: 18)),
        ),
      ],
    );

    _conversations['c-jules'] = _MockConversation(
      id: 'c-jules',
      userId: jules.id,
      unreadCount: 1,
      messages: [
        MessageEntity(
          id: _nextId('m'),
          isMine: true,
          text: 'How was the midnight meet?',
          sentAt: now.subtract(const Duration(hours: 1, minutes: 10)),
          isSeen: true,
        ),
        MessageEntity(
          id: _nextId('m'),
          isMine: false,
          text: '112 cars this year — insane turnout',
          sentAt: now.subtract(const Duration(hours: 1)),
        ),
      ],
    );

    _conversations['c-kenji'] = _MockConversation(
      id: 'c-kenji',
      userId: kenji.id,
      myLastMessageSeen: true,
      messages: [
        MessageEntity(
          id: _nextId('m'),
          isMine: false,
          text: 'Saw the NSX at cars & coffee — the paint is insane in '
              'person',
          sentAt: now.subtract(const Duration(hours: 3, minutes: 12)),
        ),
        MessageEntity(
          id: _nextId('m'),
          isMine: true,
          text: 'worth every hour of detailing',
          sentAt: now.subtract(const Duration(hours: 3)),
          isSeen: true,
        ),
      ],
    );

    _conversations['c-leo'] = _MockConversation(
      id: 'c-leo',
      userId: leo.id,
      messages: [
        MessageEntity(
          id: _nextId('m'),
          isMine: false,
          kind: MessageKind.sharedPost,
          sharedPost: const MessageSharedPostEntity(
            postId: 'post-stance',
            authorUsername: 'low_n_slow_leo',
            caption: 'Static or bagged — settle it in the comments',
          ),
          sentAt: now.subtract(const Duration(hours: 5)),
        ),
      ],
    );

    _conversations['c-rae'] = _MockConversation(
      id: 'c-rae',
      userId: rae.id,
      messages: [
        MessageEntity(
          id: _nextId('m'),
          isMine: false,
          text: 'Sent you the tuning specs 🔧',
          sentAt: now.subtract(const Duration(days: 1)),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------- inbox

  @override
  Future<InboxEntity> getInbox() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final sorted = _conversations.values.toList()
      ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));

    return InboxEntity(
      activeNow: _users.values.where((u) => u.isOnline).toList(),
      requestsCount: 4,
      requestsPreviewNames: const ['vroom_valeria', 'noctis_nico'],
      conversations: [
        for (final conversation in sorted)
          if (conversation.messages.isNotEmpty)
            conversation.toEntity(_users[conversation.userId]!),
      ],
    );
  }

  // ----------------------------------------------------------------- chat

  @override
  Future<ChatEntity> getChat(String conversationId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final conversation = _conversations[conversationId];
    if (conversation == null) {
      throw StateError('Unknown conversation: $conversationId');
    }

    conversation.unreadCount = 0;
    return ChatEntity(
      conversationId: conversation.id,
      user: _users[conversation.userId]!,
      messages: List.unmodifiable(conversation.messages),
    );
  }

  @override
  Future<MessageEntity> sendMessage(String conversationId, String text) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final conversation = _conversations[conversationId]!;
    final message = MessageEntity(
      id: _nextId('m'),
      isMine: true,
      text: text,
      sentAt: DateTime.now(),
    );
    conversation
      ..messages.add(message)
      ..myLastMessageSeen = false;

    _scheduleReplyChoreography(conversation);
    return message;
  }

  @override
  Stream<ChatIncomingEvent> chatEvents(String conversationId) =>
      _controllerFor(conversationId).stream;

  StreamController<ChatIncomingEvent> _controllerFor(String conversationId) =>
      _eventControllers.putIfAbsent(
        conversationId,
        () => StreamController<ChatIncomingEvent>.broadcast(),
      );

  /// After each send the partner "sees" the message, types for a bit and
  /// answers with a canned line. A newer send cancels the pending sequence.
  void _scheduleReplyChoreography(_MockConversation conversation) {
    for (final timer in _replyTimers[conversation.id] ?? <Timer>[]) {
      timer.cancel();
    }
    final controller = _controllerFor(conversation.id);

    _replyTimers[conversation.id] = [
      Timer(const Duration(milliseconds: 900), () {
        _markMineSeen(conversation);
        controller.add(const ChatMessagesSeen());
      }),
      Timer(const Duration(milliseconds: 1900), () {
        controller.add(const ChatPartnerTyping(true));
      }),
      Timer(const Duration(milliseconds: 3800), () {
        final reply = MessageEntity(
          id: _nextId('m'),
          isMine: false,
          text: _cannedReplies[_replySeq++ % _cannedReplies.length],
          sentAt: DateTime.now(),
        );
        conversation.messages.add(reply);
        controller
          ..add(const ChatPartnerTyping(false))
          ..add(ChatMessageArrived(reply));
      }),
    ];
  }

  void _markMineSeen(_MockConversation conversation) {
    for (var i = 0; i < conversation.messages.length; i++) {
      final message = conversation.messages[i];
      if (message.isMine && !message.isSeen) {
        conversation.messages[i] = message.copyWith(isSeen: true);
      }
    }
    conversation.myLastMessageSeen = true;
  }

  // -------------------------------------------------------------- compose

  @override
  Future<List<MessageUserEntity>> getComposeSuggestions(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final needle = query.trim().toLowerCase();
    return _users.values
        .where((u) => needle.isEmpty || u.username.contains(needle))
        .toList();
  }

  @override
  Future<String> startConversation(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final existing = _conversations.values
        .where((c) => c.userId == userId)
        .toList();
    if (existing.isNotEmpty) return existing.first.id;

    final conversation = _MockConversation(
      id: _nextId('c'),
      userId: userId,
      messages: [],
    );
    _conversations[conversation.id] = conversation;
    return conversation.id;
  }
}

/// Mutable conversation state inside the mock.
class _MockConversation {
  final String id;
  final String userId;
  final List<MessageEntity> messages;
  int unreadCount;
  bool myLastMessageSeen;

  _MockConversation({
    required this.id,
    required this.userId,
    required this.messages,
    this.unreadCount = 0,
    this.myLastMessageSeen = false,
  });

  DateTime get lastMessageAt =>
      messages.isEmpty ? DateTime.now() : messages.last.sentAt;

  ConversationEntity toEntity(MessageUserEntity user) {
    final last = messages.last;
    return ConversationEntity(
      id: id,
      user: user,
      preview: last.kind == MessageKind.sharedPost
          ? (last.sharedPost?.caption ?? '')
          : (last.text ?? ''),
      previewKind: last.kind == MessageKind.sharedPost
          ? ConversationPreviewKind.sharedPost
          : ConversationPreviewKind.text,
      isLastMessageMine: last.isMine,
      lastMessageAt: last.sentAt,
      unreadCount: unreadCount,
      lastMessageSeen: last.isMine && myLastMessageSeen,
    );
  }
}
