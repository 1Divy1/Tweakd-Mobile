import 'package:equatable/equatable.dart';

import '../../../domain/entities/chat.dart';
import '../../../domain/entities/chat_events.dart';
import '../../../domain/entities/message_user.dart';
import '../../../domain/entities/presence.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Opens a chat with [peer]. [conversationId] is null when composing to a
/// user with no known conversation yet — the first send adopts the id the
/// server returns.
class LoadChat extends ChatEvent {
  final String? conversationId;
  final MessageUserEntity peer;
  const LoadChat({required this.conversationId, required this.peer});

  @override
  List<Object?> get props => [conversationId, peer];
}

/// Fetches the next (older) history page when scrolling up.
class LoadOlderMessages extends ChatEvent {
  const LoadOlderMessages();
}

class SendChatMessage extends ChatEvent {
  final String text;
  const SendChatMessage(this.text);

  @override
  List<Object?> get props => [text];
}

/// Soft-deletes the viewer's own message.
class DeleteChatMessage extends ChatEvent {
  final String messageId;
  const DeleteChatMessage(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

/// The composer's text changed — drives the throttled typing signal.
class ChatComposerChanged extends ChatEvent {
  final bool hasText;
  const ChatComposerChanged({required this.hasText});

  @override
  List<Object?> get props => [hasText];
}

/// Internal: a live event (seen / typing / incoming / deleted) arrived on
/// the chat stream. Added by the bloc's own subscription, not by widgets.
class ChatStreamEventReceived extends ChatEvent {
  final ChatIncomingEvent incoming;
  const ChatStreamEventReceived(this.incoming);

  @override
  List<Object?> get props => [incoming];
}

/// Internal: history fetched after the first send adopted a conversation id
/// (covers messaging someone whose conversation was hidden or not loaded).
/// Added by the bloc's own plumbing, not by widgets.
class ChatHistoryBackfilled extends ChatEvent {
  final String conversationId;
  final MessagesPageEntity page;
  const ChatHistoryBackfilled({
    required this.conversationId,
    required this.page,
  });

  @override
  List<Object?> get props => [conversationId, page];
}

/// Internal: the peer's presence changed — either the initial batch lookup
/// resolved or a live flip arrived on the DM socket. Added by the bloc's own
/// plumbing, not by widgets.
class ChatPeerPresenceChanged extends ChatEvent {
  final PresenceEntity presence;
  const ChatPeerPresenceChanged(this.presence);

  @override
  List<Object?> get props => [presence];
}
