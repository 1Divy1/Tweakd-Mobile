import 'package:equatable/equatable.dart';

import '../../../domain/entities/chat_events.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChat extends ChatEvent {
  final String conversationId;
  const LoadChat(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class SendChatMessage extends ChatEvent {
  final String text;
  const SendChatMessage(this.text);

  @override
  List<Object?> get props => [text];
}

/// Internal: a live event (seen / typing / incoming message) arrived on the
/// chat stream. Added by the bloc's own subscription, not by widgets.
class ChatStreamEventReceived extends ChatEvent {
  final ChatIncomingEvent incoming;
  const ChatStreamEventReceived(this.incoming);

  @override
  List<Object?> get props => [incoming];
}
