import 'package:equatable/equatable.dart';

import 'message.dart';
import 'message_user.dart';

/// What the last message of a conversation was, for the inbox preview line.
/// [deleted] = the last message was soft-deleted (wire sends a null preview).
enum ConversationPreviewKind { text, sharedPost, attachment, deleted }

/// One row of the inbox list.
class ConversationEntity extends Equatable {
  final String id;
  final MessageUserEntity user;
  final String preview;
  final ConversationPreviewKind previewKind;

  /// True when the viewer sent the last message ("You: …" prefix).
  final bool isLastMessageMine;
  final DateTime lastMessageAt;
  final int unreadCount;

  /// True when the viewer's own last message has been seen by the other
  /// user — renders the mini-avatar receipt instead of an unread badge.
  final bool lastMessageSeen;

  const ConversationEntity({
    required this.id,
    required this.user,
    required this.preview,
    this.previewKind = ConversationPreviewKind.text,
    this.isLastMessageMine = false,
    required this.lastMessageAt,
    this.unreadCount = 0,
    this.lastMessageSeen = false,
  });

  @override
  List<Object?> get props => [
        id,
        user,
        preview,
        previewKind,
        isLastMessageMine,
        lastMessageAt,
        unreadCount,
        lastMessageSeen,
      ];
}

/// Everything the inbox screen needs in one load.
class InboxEntity extends Equatable {
  final int requestsCount;

  /// Usernames previewed on the requests tile ("vroom_valeria, noctis_nico
  /// & 2 others"). No backend source yet — the tile hides when
  /// [requestsCount] is 0.
  final List<String> requestsPreviewNames;
  final List<ConversationEntity> conversations;

  /// Keyset cursor for the next page of conversations; null = last page.
  final String? nextCursor;

  const InboxEntity({
    this.requestsCount = 0,
    this.requestsPreviewNames = const [],
    this.conversations = const [],
    this.nextCursor,
  });

  /// Keeps [nextCursor] — pagination appends construct a new entity instead.
  InboxEntity copyWith({
    List<ConversationEntity>? conversations,
  }) =>
      InboxEntity(
        requestsCount: requestsCount,
        requestsPreviewNames: requestsPreviewNames,
        conversations: conversations ?? this.conversations,
        nextCursor: nextCursor,
      );

  @override
  List<Object?> get props =>
      [requestsCount, requestsPreviewNames, conversations, nextCursor];
}

/// Live updates for the inbox list.
sealed class InboxLiveEvent extends Equatable {
  const InboxLiveEvent();

  @override
  List<Object?> get props => [];
}

/// The live connection (re)opened. Messages sent while it was down were
/// missed, so the list should refetch.
class InboxLiveConnected extends InboxLiveEvent {
  const InboxLiveConnected();
}

/// A live "new message" ping for the inbox: enough to update one row's
/// preview/ordering/unread without refetching the list.
class InboxMessageEvent extends InboxLiveEvent {
  final String conversationId;
  final MessageEntity message;

  const InboxMessageEvent({
    required this.conversationId,
    required this.message,
  });

  @override
  List<Object?> get props => [conversationId, message];
}

