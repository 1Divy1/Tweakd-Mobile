import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/chat_events.dart';
import '../../../domain/usecases/get_chat.dart';
import '../../../domain/usecases/send_message.dart';
import '../../../domain/usecases/watch_chat.dart';
import '../../utils/messages_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Drives one open conversation: loads the history, sends messages and folds
/// the live event stream (read receipts, typing, incoming messages) into the
/// state so the UI can animate them.
@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChatUseCase getChat;
  final SendMessageUseCase sendMessage;
  final WatchChatUseCase watchChat;

  StreamSubscription<ChatIncomingEvent>? _eventsSubscription;

  ChatBloc({
    required this.getChat,
    required this.sendMessage,
    required this.watchChat,
  }) : super(const ChatInitial()) {
    on<LoadChat>(_onLoad);
    on<SendChatMessage>(_onSend);
    on<ChatStreamEventReceived>(_onStreamEvent);
  }

  @override
  Future<void> close() async {
    await _eventsSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoad(LoadChat event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());
    final result = await getChat(event.conversationId);
    result.fold(
      (failure) => emit(ChatError(MessagesErrorMapper.getCode(failure))),
      (chat) {
        emit(ChatLoaded(
          conversationId: chat.conversationId,
          user: chat.user,
          messages: chat.messages,
        ));
        _eventsSubscription?.cancel();
        _eventsSubscription = watchChat(event.conversationId)
            .listen((incoming) => add(ChatStreamEventReceived(incoming)));
      },
    );
  }

  Future<void> _onSend(SendChatMessage event, Emitter<ChatState> emit) async {
    final current = state;
    if (current is! ChatLoaded) return;
    final text = event.text.trim();
    if (text.isEmpty) return;

    final result = await sendMessage(SendMessageParams(
      conversationId: current.conversationId,
      text: text,
    ));
    result.fold(
      (_) {}, // mock never fails; real error surfacing comes with the backend
      (message) {
        final latest = state;
        if (latest is! ChatLoaded) return;
        emit(latest.copyWith(
          messages: [...latest.messages, message],
          animatedMessageIds: {...latest.animatedMessageIds, message.id},
        ));
      },
    );
  }

  void _onStreamEvent(
    ChatStreamEventReceived event,
    Emitter<ChatState> emit,
  ) {
    final current = state;
    if (current is! ChatLoaded) return;

    switch (event.incoming) {
      case ChatMessagesSeen():
        emit(current.copyWith(
          messages: [
            for (final message in current.messages)
              message.isMine && !message.isSeen
                  ? message.copyWith(isSeen: true)
                  : message,
          ],
        ));
      case ChatPartnerTyping(:final isTyping):
        emit(current.copyWith(partnerTyping: isTyping));
      case ChatMessageArrived(:final message):
        if (current.messages.any((m) => m.id == message.id)) return;
        emit(current.copyWith(
          messages: [...current.messages, message],
          partnerTyping: false,
          animatedMessageIds: {...current.animatedMessageIds, message.id},
        ));
    }
  }
}
