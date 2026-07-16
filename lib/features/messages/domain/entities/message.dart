import 'package:equatable/equatable.dart';

enum MessageKind { text, sharedPost }

/// A post shared into a conversation, rendered as a card bubble.
class MessageSharedPostEntity extends Equatable {
  final String postId;
  final String authorUsername;
  final String? authorAvatarUrl;
  final String? imageUrl;
  final String? caption;

  const MessageSharedPostEntity({
    required this.postId,
    required this.authorUsername,
    this.authorAvatarUrl,
    this.imageUrl,
    this.caption,
  });

  @override
  List<Object?> get props =>
      [postId, authorUsername, authorAvatarUrl, imageUrl, caption];
}

/// A single message inside a conversation.
class MessageEntity extends Equatable {
  final String id;
  final bool isMine;
  final MessageKind kind;
  final String? text;
  final MessageSharedPostEntity? sharedPost;
  final DateTime sentAt;

  /// Read receipt for the viewer's own messages ("Seen").
  final bool isSeen;

  /// Soft-deleted by its sender — rendered as a "message deleted"
  /// placeholder; [text] is empty on the wire.
  final bool isDeleted;

  const MessageEntity({
    required this.id,
    required this.isMine,
    this.kind = MessageKind.text,
    this.text,
    this.sharedPost,
    required this.sentAt,
    this.isSeen = false,
    this.isDeleted = false,
  });

  MessageEntity copyWith({bool? isSeen, bool? isDeleted}) => MessageEntity(
        id: id,
        isMine: isMine,
        kind: kind,
        text: text,
        sharedPost: sharedPost,
        sentAt: sentAt,
        isSeen: isSeen ?? this.isSeen,
        isDeleted: isDeleted ?? this.isDeleted,
      );

  @override
  List<Object?> get props =>
      [id, isMine, kind, text, sharedPost, sentAt, isSeen, isDeleted];
}

/// Result of sending a DM. The conversation id matters because a first
/// message between two users creates the conversation implicitly — a chat
/// opened from compose adopts this id.
class SentMessageEntity extends Equatable {
  final String conversationId;
  final MessageEntity message;

  const SentMessageEntity({
    required this.conversationId,
    required this.message,
  });

  @override
  List<Object?> get props => [conversationId, message];
}
