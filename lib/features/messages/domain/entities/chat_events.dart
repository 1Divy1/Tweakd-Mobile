import 'package:equatable/equatable.dart';

import 'message.dart';

/// Live events pushed into an open chat, mapped from the DM socket.
sealed class ChatIncomingEvent extends Equatable {
  const ChatIncomingEvent();

  @override
  List<Object?> get props => [];
}

/// The other user read the conversation. [upToMessageId] is their read
/// watermark — the viewer's messages up to and including it are "Seen".
/// Null means everything currently loaded (legacy mock semantics).
class ChatMessagesSeen extends ChatIncomingEvent {
  final String? upToMessageId;
  const ChatMessagesSeen({this.upToMessageId});

  @override
  List<Object?> get props => [upToMessageId];
}

/// The other user started/stopped typing.
class ChatPartnerTyping extends ChatIncomingEvent {
  final bool isTyping;
  const ChatPartnerTyping(this.isTyping);

  @override
  List<Object?> get props => [isTyping];
}

/// A new message arrived (from the peer, or from the viewer's own other
/// device — [MessageEntity.isMine] distinguishes them).
class ChatMessageArrived extends ChatIncomingEvent {
  final MessageEntity message;
  const ChatMessageArrived(this.message);

  @override
  List<Object?> get props => [message];
}

/// The live connection (re)opened. Events sent while it was down were
/// missed, so the chat should refetch its latest page.
class ChatLiveConnected extends ChatIncomingEvent {
  const ChatLiveConnected();
}

/// A message in this conversation was soft-deleted by its sender.
class ChatMessageDeleted extends ChatIncomingEvent {
  final String messageId;
  const ChatMessageDeleted(this.messageId);

  @override
  List<Object?> get props => [messageId];
}
