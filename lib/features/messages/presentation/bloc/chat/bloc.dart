import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/chat_events.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/entities/presence.dart';
import '../../../domain/usecases/get_messages.dart';
import '../../../domain/usecases/message_actions.dart';
import '../../../domain/usecases/presence.dart';
import '../../../domain/usecases/send_message.dart';
import '../../../domain/usecases/watch_chat.dart';
import '../../utils/messages_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Drives one open conversation against the real backend: paged history,
/// sending (which may create the conversation), read receipts via the peer's
/// watermark, deletions, and the live socket stream (typing, incoming and
/// deleted messages). The peer's presence is fetched once on open and then
/// kept live from the socket.
@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetMessagesUseCase getMessages;
  final SendMessageUseCase sendMessage;
  final DeleteMessageUseCase deleteMessage;
  final MarkConversationReadUseCase markConversationRead;
  final SendTypingUseCase sendTyping;
  final WatchChatUseCase watchChat;
  final GetPresenceUseCase getPresence;
  final WatchPresenceUseCase watchPresence;

  StreamSubscription<ChatIncomingEvent>? _eventsSubscription;
  StreamSubscription<PresenceEntity>? _presenceSubscription;

  /// Typing throttle: resend `typing: true` at most every [_typingResend].
  static const _typingResend = Duration(milliseconds: 2500);
  DateTime? _lastTypingSentAt;
  bool _typingActive = false;

  /// Safety net: clear the partner-typing bubble if no further signal lands.
  Timer? _partnerTypingTimeout;

  ChatBloc({
    required this.getMessages,
    required this.sendMessage,
    required this.deleteMessage,
    required this.markConversationRead,
    required this.sendTyping,
    required this.watchChat,
    required this.getPresence,
    required this.watchPresence,
  }) : super(const ChatInitial()) {
    on<LoadChat>(_onLoad);
    on<LoadOlderMessages>(_onLoadOlder);
    on<SendChatMessage>(_onSend);
    on<DeleteChatMessage>(_onDelete);
    on<ChatComposerChanged>(_onComposerChanged);
    on<ChatStreamEventReceived>(_onStreamEvent);
    on<ChatHistoryBackfilled>(_onHistoryBackfilled);
    on<ChatPeerPresenceChanged>(_onPeerPresenceChanged);
  }

  @override
  Future<void> close() async {
    _partnerTypingTimeout?.cancel();
    _stopTypingIfActive();
    await _eventsSubscription?.cancel();
    await _presenceSubscription?.cancel();
    return super.close();
  }

  void _stopTypingIfActive() {
    final current = state;
    if (_typingActive && current is ChatLoaded) {
      final conversationId = current.conversationId;
      if (conversationId != null) {
        sendTyping(conversationId, isTyping: false);
      }
    }
    _typingActive = false;
  }

  // ------------------------------------------------------------------ load

  Future<void> _onLoad(LoadChat event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());
    _watchPeerPresence(event.peer.id);

    final conversationId = event.conversationId;
    if (conversationId == null) {
      // Compose flow: no conversation yet — empty chat, nothing to fetch.
      emit(ChatLoaded(
        conversationId: null,
        user: event.peer,
        messages: const [],
      ));
      unawaited(_refreshPeerPresence(event.peer.id));
      return;
    }

    final result = await getMessages(
      GetMessagesParams(conversationId: conversationId),
    );
    result.fold(
      (failure) => emit(ChatError(MessagesErrorMapper.getCode(failure))),
      (page) {
        emit(ChatLoaded(
          conversationId: conversationId,
          user: event.peer,
          messages: _applySeen(page.messages, page.peerLastReadMessageId),
          olderCursor: page.nextCursor,
          peerLastReadMessageId: page.peerLastReadMessageId,
        ));
        _watchConversation(conversationId);
        unawaited(markConversationRead(conversationId));
        unawaited(_refreshPeerPresence(event.peer.id));
      },
    );
  }

  Future<void> _onLoadOlder(
    LoadOlderMessages event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    if (current is! ChatLoaded ||
        current.isLoadingOlder ||
        current.olderCursor == null ||
        current.conversationId == null) {
      return;
    }

    emit(current.copyWith(isLoadingOlder: true));
    final result = await getMessages(GetMessagesParams(
      conversationId: current.conversationId!,
      cursor: current.olderCursor,
    ));

    final latest = state;
    if (latest is! ChatLoaded) return;
    result.fold(
      (_) => emit(latest.copyWith(isLoadingOlder: false)),
      (page) {
        final knownIds = {for (final m in latest.messages) m.id};
        final older = [
          for (final message in page.messages)
            if (!knownIds.contains(message.id)) message,
        ];
        emit(latest.copyWith(
          messages: _applySeen(
            [...older, ...latest.messages],
            latest.peerLastReadMessageId,
          ),
          olderCursor: page.nextCursor,
          isLoadingOlder: false,
        ));
      },
    );
  }

  // ------------------------------------------------------------------ send

  Future<void> _onSend(SendChatMessage event, Emitter<ChatState> emit) async {
    final current = state;
    if (current is! ChatLoaded) return;
    final text = event.text.trim();
    if (text.isEmpty) return;

    _stopTypingIfActive();
    final hadConversation = current.conversationId != null;

    final result = await sendMessage(SendMessageParams(
      recipientId: current.user.id,
      text: text,
    ));

    final latest = state;
    if (latest is! ChatLoaded) return;
    result.fold(
      (failure) => emit(latest.copyWith(
        actionError: MessagesErrorMapper.getCode(failure),
      )),
      (sent) {
        if (latest.messages.any((m) => m.id == sent.message.id)) return;
        emit(latest.copyWith(
          conversationId: sent.conversationId,
          messages: [...latest.messages, sent.message],
          animatedMessageIds: {
            ...latest.animatedMessageIds,
            sent.message.id,
          },
        ));
        if (!hadConversation) {
          // First message created (or resurfaced) the conversation: start
          // listening and pull history in case a hidden one already existed.
          _watchConversation(sent.conversationId);
          unawaited(_backfillHistory(sent.conversationId));
        }
      },
    );
  }

  /// After adopting a conversation id from the first send, fetch any history
  /// the server already had and hand it to [_onHistoryBackfilled].
  Future<void> _backfillHistory(String conversationId) async {
    final result = await getMessages(
      GetMessagesParams(conversationId: conversationId),
    );
    result.fold(
      (_) {}, // cosmetic backfill — the sent message is already visible
      (page) {
        if (isClosed) return;
        add(ChatHistoryBackfilled(conversationId: conversationId, page: page));
      },
    );
  }

  void _onHistoryBackfilled(
    ChatHistoryBackfilled event,
    Emitter<ChatState> emit,
  ) {
    final current = state;
    if (current is! ChatLoaded ||
        current.conversationId != event.conversationId) {
      return;
    }
    final page = event.page;
    final knownIds = {for (final m in current.messages) m.id};
    final missing = [
      for (final message in page.messages)
        if (!knownIds.contains(message.id)) message,
    ];
    if (missing.isEmpty && page.nextCursor == null) return;
    final merged = [...current.messages, ...missing]
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
    emit(current.copyWith(
      messages: _applySeen(merged, page.peerLastReadMessageId),
      olderCursor: page.nextCursor,
      peerLastReadMessageId: page.peerLastReadMessageId,
    ));
  }

  // --------------------------------------------------------------- actions

  Future<void> _onDelete(
    DeleteChatMessage event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    if (current is! ChatLoaded) return;

    final result = await deleteMessage(event.messageId);
    final latest = state;
    if (latest is! ChatLoaded) return;
    result.fold(
      (failure) => emit(latest.copyWith(
        actionError: MessagesErrorMapper.getCode(failure),
      )),
      (_) => emit(latest.copyWith(
        messages: _markDeleted(latest.messages, event.messageId),
      )),
    );
  }

  void _onComposerChanged(ChatComposerChanged event, Emitter<ChatState> emit) {
    final current = state;
    if (current is! ChatLoaded) return;
    final conversationId = current.conversationId;
    if (conversationId == null) return;

    if (event.hasText) {
      final now = DateTime.now();
      final last = _lastTypingSentAt;
      if (!_typingActive ||
          last == null ||
          now.difference(last) >= _typingResend) {
        sendTyping(conversationId, isTyping: true);
        _lastTypingSentAt = now;
        _typingActive = true;
      }
    } else if (_typingActive) {
      sendTyping(conversationId, isTyping: false);
      _typingActive = false;
    }
  }

  // ---------------------------------------------------------- live events

  void _onStreamEvent(
    ChatStreamEventReceived event,
    Emitter<ChatState> emit,
  ) {
    final current = state;
    if (current is! ChatLoaded) return;

    switch (event.incoming) {
      case ChatMessagesSeen(:final upToMessageId):
        emit(current.copyWith(
          messages: _applySeen(
            current.messages,
            upToMessageId,
            markAll: upToMessageId == null,
          ),
          peerLastReadMessageId:
              upToMessageId ?? current.peerLastReadMessageId,
        ));
      case ChatPartnerTyping(:final isTyping):
        _partnerTypingTimeout?.cancel();
        if (isTyping) {
          _partnerTypingTimeout = Timer(const Duration(seconds: 8), () {
            if (!isClosed) {
              add(const ChatStreamEventReceived(ChatPartnerTyping(false)));
            }
          });
        }
        emit(current.copyWith(partnerTyping: isTyping));
      case ChatMessageArrived(:final message):
        if (current.messages.any((m) => m.id == message.id)) return;
        emit(current.copyWith(
          messages: [...current.messages, message],
          partnerTyping: message.isMine ? null : false,
          animatedMessageIds: {...current.animatedMessageIds, message.id},
        ));
        final conversationId = current.conversationId;
        if (!message.isMine && conversationId != null) {
          // Viewer has the chat open — flip the peer's "Seen" immediately.
          unawaited(markConversationRead(conversationId));
        }
      case ChatMessageDeleted(:final messageId):
        emit(current.copyWith(
          messages: _markDeleted(current.messages, messageId),
        ));
    }
  }

  void _onPeerPresenceChanged(
    ChatPeerPresenceChanged event,
    Emitter<ChatState> emit,
  ) {
    final current = state;
    if (current is! ChatLoaded) return;
    if (event.presence.userId != current.user.id) return;

    emit(current.copyWith(
      user: current.user.withPresence(
        isOnline: event.presence.online,
        lastSeenAt: event.presence.lastSeenAt,
      ),
    ));
  }

  // -------------------------------------------------------------- plumbing

  void _watchConversation(String conversationId) {
    _eventsSubscription?.cancel();
    _eventsSubscription = watchChat(conversationId)
        .listen((incoming) => add(ChatStreamEventReceived(incoming)));
  }

  void _watchPeerPresence(String peerId) {
    _presenceSubscription?.cancel();
    _presenceSubscription = watchPresence()
        .where((presence) => presence.userId == peerId)
        .listen((presence) => add(ChatPeerPresenceChanged(presence)));
  }

  Future<void> _refreshPeerPresence(String userId) async {
    final result = await getPresence([userId]);
    result.fold(
      (_) {}, // presence is cosmetic — swallow lookup failures
      (entries) {
        for (final presence in entries) {
          if (presence.userId == userId && !isClosed) {
            add(ChatPeerPresenceChanged(presence));
          }
        }
      },
    );
  }

  /// Marks the viewer's messages read up to the watermark id ([markAll]
  /// covers a watermark-less seen event). Messages positioned after a
  /// watermark that isn't in the loaded window stay untouched.
  List<MessageEntity> _applySeen(
    List<MessageEntity> messages,
    String? upToMessageId, {
    bool markAll = false,
  }) {
    if (markAll) {
      return [
        for (final message in messages)
          message.isMine && !message.isSeen
              ? message.copyWith(isSeen: true)
              : message,
      ];
    }
    if (upToMessageId == null) return messages;
    final watermarkIndex =
        messages.indexWhere((message) => message.id == upToMessageId);
    if (watermarkIndex < 0) return messages;
    return [
      for (var i = 0; i < messages.length; i++)
        i <= watermarkIndex && messages[i].isMine && !messages[i].isSeen
            ? messages[i].copyWith(isSeen: true)
            : messages[i],
    ];
  }

  List<MessageEntity> _markDeleted(
    List<MessageEntity> messages,
    String messageId,
  ) =>
      [
        for (final message in messages)
          message.id == messageId
              ? message.copyWith(isDeleted: true)
              : message,
      ];
}
