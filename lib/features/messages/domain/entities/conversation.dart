import 'package:equatable/equatable.dart';

import 'message_user.dart';

/// What the last message of a conversation was, for the inbox preview line.
enum ConversationPreviewKind { text, sharedPost, attachment }

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
  final List<MessageUserEntity> activeNow;
  final int requestsCount;

  /// Usernames previewed on the requests tile ("vroom_valeria, noctis_nico
  /// & 2 others").
  final List<String> requestsPreviewNames;
  final List<ConversationEntity> conversations;

  const InboxEntity({
    this.activeNow = const [],
    this.requestsCount = 0,
    this.requestsPreviewNames = const [],
    this.conversations = const [],
  });

  @override
  List<Object?> get props =>
      [activeNow, requestsCount, requestsPreviewNames, conversations];
}

