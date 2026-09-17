import 'dart:async';

import 'package:equatable/equatable.dart';

import '../../../domain/entities/conversation.dart';

sealed class InboxEvent extends Equatable {
  const InboxEvent();

  @override
  List<Object?> get props => [];
}

class LoadInbox extends InboxEvent {
  const LoadInbox();
}

/// Pull-to-refresh; the completer stops the indicator (see the feed page for
/// why a completer and not a state listener). Resets to page 1.
class RefreshInbox extends InboxEvent {
  final Completer<void>? completer;
  const RefreshInbox([this.completer]);
}

/// Fetches the next conversations page when scrolling near the bottom.
class LoadMoreInbox extends InboxEvent {
  const LoadMoreInbox();
}

class InboxSearchChanged extends InboxEvent {
  final String query;
  const InboxSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// "Delete chat" — hides the conversation from the viewer's list.
class HideInboxConversation extends InboxEvent {
  final String conversationId;
  const HideInboxConversation(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// Internal: a new message landed somewhere — update that row's preview,
/// ordering and unread badge without refetching. Added by the bloc's own
/// subscription, not by widgets.
class InboxMessageReceived extends InboxEvent {
  final InboxMessageEvent event;
  const InboxMessageReceived(this.event);

  @override
  List<Object?> get props => [event];
}
