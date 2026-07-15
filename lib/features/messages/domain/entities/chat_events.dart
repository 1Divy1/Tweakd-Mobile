import 'package:equatable/equatable.dart';

import 'message.dart';

/// Live events pushed into an open chat (read receipts, typing, incoming
/// messages). Backed by the mock today; a websocket later.
sealed class ChatIncomingEvent extends Equatable {
  const ChatIncomingEvent();

  @override
  List<Object?> get props => [];
}

/// The other user has seen the viewer's messages.
class ChatMessagesSeen extends ChatIncomingEvent {
  const ChatMessagesSeen();
}

/// The other user started/stopped typing.
class ChatPartnerTyping extends ChatIncomingEvent {
  final bool isTyping;
  const ChatPartnerTyping(this.isTyping);

  @override
  List<Object?> get props => [isTyping];
}

/// A new message from the other user arrived.
class ChatMessageArrived extends ChatIncomingEvent {
  final MessageEntity message;
  const ChatMessageArrived(this.message);

  @override
  List<Object?> get props => [message];
}
