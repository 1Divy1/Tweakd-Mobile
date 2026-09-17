import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/chat.dart';
import '../../../domain/entities/chat_events.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/usecases/get_conversation_peer.dart';
import '../../../domain/usecases/get_messages.dart';
import '../../../domain/usecases/message_actions.dart';
import '../../../domain/usecases/send_message.dart';
import '../../../domain/usecases/watch_chat.dart';
import '../../utils/messages_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Drives one open conversation: paged history from Spring, sending through
/// the Supabase RPC (which may create the conversation), read receipts via the
/// peer's watermark, deletions, and the live broadcast stream (typing,
/// incoming and deleted messages). The bloc's live subscription is what holds
/// the realtime connection open while the chat is on screen.
@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetMessagesUseCase getMessages;
  final GetConversationPeerUseCase getConversationPeer;
  final SendMessageUseCase sendMessage;
  final DeleteMessageUseCase deleteMessage;
  final MarkConversationReadUseCase markConversationRead;
  final SendTypingUseCase sendTyping;
  final WatchChatUseCase watchChat;

  StreamSubscription<ChatIncomingEvent>? _eventsSubscription;

  /// Typing throttle: resend `typing: true` at most every [_typingResend].
  static const _typingResend = Duration(milliseconds: 1000);
  DateTime? _lastTypingSentAt;
  bool _typingActive = false;

  /// Safety net: clear the partner-typing bubble if no further signal lands.
  Timer? _partnerTypingTimeout;

  ChatBloc({
    required this.getMessages,
    required this.getConversationPeer,
    required this.sendMessage,
    required this.deleteMessage,
    required this.markConversationRead,
    required this.sendTyping,
    required this.watchChat,
  }) : super(const ChatInitial()) {
    on<LoadChat>(_onLoad);
    on<LoadOlderMessages>(_onLoadOlder);
    on<SendChatMessage>(_onSend);
    on<DeleteChatMessage>(_onDelete);
    on<ChatComposerChanged>(_onComposerChanged);
    on<ChatStreamEventReceived>(_onStreamEvent);
    on<ChatHistoryBackfilled>(_onHistoryBackfilled);
  }

  @override
  Future<void> close() async {
    _partnerTypingTimeout?.cancel();
    _stopTypingIfActive();
    await _eventsSubscription?.cancel();
    return super.close();
  }

  void _stopTypingIfActive() {
    final current = state;
    if (_typingActive && current is ChatLoaded) {
      final conversationId = current.conversationId;
      if (conversationId != null) {
        sendTyping(
          conversationId,
          isTyping: false,
          peerId: current.user.id,
        );
      }
    }
    _typingActive = false;
  }

  // ------------------------------------------------------------------ load

  Future<void> _onLoad(LoadChat event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());

    final conversationId = event.conversationId;
    final knownPeer = event.peer;

    if (conversationId == null) {
      // Compose flow: no conversation yet — empty chat, nothing to fetch. A
      // peer is mandatory here; there is no conversation to resolve one from.
      if (knownPeer == null) {
        emit(const ChatError(MessagesErrorCode.generic));
        return;
      }
      emit(ChatLoaded(
        conversationId: null,
        user: knownPeer,
        messages: const [],
      ));
      return;
    }

    // Opened by conversation id alone (a notification tap): the peer has to be
    // fetched. Issued *concurrently* with the history rather than before it —
    // the two are independent, and serialising them would put two round trips
    // in front of a screen the user is already looking at.
    final historyRequest = getMessages(
      GetMessagesParams(conversationId: conversationId),
    );
    final peerRequest = knownPeer != null
        ? null
        : getConversationPeer(conversationId);

    final history = await historyRequest;
    final peerResult = await peerRequest;

    final peer = knownPeer ??
        peerResult?.fold((_) => null, (resolved) => resolved);
    if (peer == null) {
      // No peer means no header and nowhere to send — the screen
      // cannot function, so this is fatal rather than degraded.
      final failure = peerResult?.fold(
        MessagesErrorMapper.getCode,
        (_) => null,
      );
      emit(ChatError(failure ?? MessagesErrorCode.generic));
      return;
    }

    history.fold(
      (failure) => emit(ChatError(MessagesErrorMapper.getCode(failure))),
      (page) {
        emit(ChatLoaded(
          conversationId: conversationId,
          user: peer,
          messages: _applySeen(page.messages, page.peerLastReadMessageId),
          olderCursor: page.nextCursor,
          peerLastReadMessageId: page.peerLastReadMessageId,
        ));
        _watchConversation(conversationId);
        unawaited(_markRead(conversationId, peer.id));
      },
    );
  }

  Future<void> _markRead(String conversationId, String peerId) =>
      markConversationRead(MarkConversationReadParams(
        conversationId: conversationId,
        peerId: peerId,
      ));

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
    // A send needs text, cars, or both — never an empty payload.
    if (text.isEmpty && event.taggedCars.isEmpty) return;

    _stopTypingIfActive();
    final hadConversation = current.conversationId != null;

    final result = await sendMessage(SendMessageParams(
      recipientId: current.user.id,
      text: text,
      taggedCars: event.taggedCars,
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

  /// Fetch the latest page and hand it to [_onHistoryBackfilled]: after
  /// adopting a conversation id from the first send (history the server
  /// already had), and after the live connection (re)opens (whatever was
  /// sent while it was down).
  Future<void> _backfillHistory(
    String conversationId, {
    bool isCatchUp = false,
  }) async {
    final result = await getMessages(
      GetMessagesParams(conversationId: conversationId),
    );
    result.fold(
      (_) {}, // cosmetic backfill — what is on screen stays usable
      (page) {
        if (isClosed) return;
        add(ChatHistoryBackfilled(
          conversationId: conversationId,
          page: page,
          isCatchUp: isCatchUp,
        ));
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

    if (event.isCatchUp) {
      _onCatchUp(current, page, missing, emit);
      return;
    }

    if (missing.isEmpty && page.nextCursor == null) return;
    final merged = [...current.messages, ...missing]
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
    emit(current.copyWith(
      messages: _applySeen(merged, page.peerLastReadMessageId),
      olderCursor: page.nextCursor,
      peerLastReadMessageId: page.peerLastReadMessageId,
    ));
  }

  /// Merges what was sent while the live connection was down. The loaded
  /// window and its older-page cursor stay as they are — unless more than a
  /// whole page was missed, in which case there is a hole in the middle and
  /// the chat restarts from the latest page.
  void _onCatchUp(
    ChatLoaded current,
    MessagesPageEntity page,
    List<MessageEntity> missing,
    Emitter<ChatState> emit,
  ) {
    final watermark =
        page.peerLastReadMessageId ?? current.peerLastReadMessageId;
    if (missing.isEmpty && watermark == current.peerLastReadMessageId) return;

    final overlaps = missing.length < page.messages.length;
    if (overlaps || page.nextCursor == null) {
      final merged = [...current.messages, ...missing]
        ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
      emit(current.copyWith(
        messages: _applySeen(merged, watermark),
        peerLastReadMessageId: watermark,
      ));
    } else {
      emit(current.copyWith(
        messages: _applySeen(page.messages, watermark),
        olderCursor: page.nextCursor,
        peerLastReadMessageId: watermark,
      ));
    }

    // The chat is on screen, so anything the peer sent meanwhile is read —
    // the stream path does the same per message.
    if (missing.any((message) => !message.isMine)) {
      unawaited(_markRead(current.conversationId!, current.user.id));
    }
  }

  // --------------------------------------------------------------- actions

  Future<void> _onDelete(
    DeleteChatMessage event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    if (current is! ChatLoaded) return;
    final conversationId = current.conversationId;
    if (conversationId == null) return;

    final result = await deleteMessage(DeleteMessageParams(
      messageId: event.messageId,
      conversationId: conversationId,
      peerId: current.user.id,
    ));
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
        sendTyping(
          conversationId,
          isTyping: true,
          peerId: current.user.id,
        );
        _lastTypingSentAt = now;
        _typingActive = true;
      }
    } else if (_typingActive) {
      sendTyping(
        conversationId,
        isTyping: false,
        peerId: current.user.id,
      );
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
      case ChatLiveConnected():
        final conversationId = current.conversationId;
        if (conversationId != null) {
          unawaited(_backfillHistory(conversationId, isCatchUp: true));
        }
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
          _partnerTypingTimeout = Timer(const Duration(seconds: 3), () {
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
          unawaited(_markRead(conversationId, current.user.id));
        }
      case ChatMessageDeleted(:final messageId):
        emit(current.copyWith(
          messages: _markDeleted(current.messages, messageId),
        ));
    }
  }

  // -------------------------------------------------------------- plumbing

  void _watchConversation(String conversationId) {
    _eventsSubscription?.cancel();
    _eventsSubscription = watchChat(conversationId)
        .listen((incoming) => add(ChatStreamEventReceived(incoming)));
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
