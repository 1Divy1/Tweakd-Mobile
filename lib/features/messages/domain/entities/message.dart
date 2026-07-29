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

/// A car shared from the sender's garage, rendered as a card inside the
/// message bubble. Mirrors only what the card/chip needs — the full car lives
/// behind the about-car route, reachable by [id].
class DmTaggedCarEntity extends Equatable {
  final String id;
  final String brand;
  final String model;

  /// Public cover image URL (garage `cover_image.url`); null when the car has
  /// no cover.
  final String? coverImageUrl;

  const DmTaggedCarEntity({
    required this.id,
    required this.brand,
    required this.model,
    this.coverImageUrl,
  });

  @override
  List<Object?> get props => [id, brand, model, coverImageUrl];
}

/// A single message inside a conversation.
class MessageEntity extends Equatable {
  final String id;
  final bool isMine;
  final MessageKind kind;
  final String? text;
  final MessageSharedPostEntity? sharedPost;

  /// Cars shared from the sender's garage. Empty for a plain text message; a
  /// message with a blank [text] and a non-empty list is a "car share".
  /// Always empty when [isDeleted]. May also be empty on a car-share message
  /// whose cars were all later deleted from their garage — the UI then falls
  /// back to a "shared cars" label.
  final List<DmTaggedCarEntity> taggedCars;
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
    this.taggedCars = const [],
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
        // A soft-deleted message loses its shared cars (matches the wire, where
        // deleted messages always carry an empty tagged_cars).
        taggedCars: (isDeleted ?? this.isDeleted) ? const [] : taggedCars,
        sentAt: sentAt,
        isSeen: isSeen ?? this.isSeen,
        isDeleted: isDeleted ?? this.isDeleted,
      );

  @override
  List<Object?> get props =>
      [id, isMine, kind, text, sharedPost, taggedCars, sentAt, isSeen, isDeleted];
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
