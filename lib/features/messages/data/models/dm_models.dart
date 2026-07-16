import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_user.dart';

DateTime _parseInstant(dynamic raw) =>
    (raw is String ? DateTime.tryParse(raw)?.toLocal() : null) ??
    DateTime.now();

/// `peer` object on a conversation row — also the shape of
/// `GET /profile/search` results reused by the compose sheet.
class DmPeerModel {
  final String id;
  final String username;
  final String? avatarUrl;

  const DmPeerModel({
    required this.id,
    required this.username,
    this.avatarUrl,
  });

  factory DmPeerModel.fromJson(Map<String, dynamic> json) => DmPeerModel(
        id: json['id'] as String,
        username: json['username'] as String? ?? '',
        avatarUrl: json['avatar_url'] as String?,
      );

  MessageUserEntity toEntity({
    bool isOnline = false,
    DateTime? lastSeenAt,
  }) =>
      MessageUserEntity(
        id: id,
        username: username,
        avatarUrl: avatarUrl,
        isOnline: isOnline,
        lastSeenAt: lastSeenAt,
      );
}

/// One row of `GET /dms/conversations`.
class DmConversationModel {
  final String id;
  final DmPeerModel peer;

  /// Null when the last message was soft-deleted.
  final String? lastMessagePreview;
  final String? lastMessageSenderId;
  final DateTime lastMessageAt;
  final int unreadCount;
  final bool peerOnline;
  final DateTime? peerLastSeenAt;

  const DmConversationModel({
    required this.id,
    required this.peer,
    this.lastMessagePreview,
    this.lastMessageSenderId,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.peerOnline,
    this.peerLastSeenAt,
  });

  factory DmConversationModel.fromJson(Map<String, dynamic> json) {
    final lastSeenRaw = json['peer_last_seen_at'];
    return DmConversationModel(
      id: json['id'] as String,
      peer: DmPeerModel.fromJson(json['peer'] as Map<String, dynamic>),
      lastMessagePreview: json['last_message_preview'] as String?,
      lastMessageSenderId: json['last_message_sender_id'] as String?,
      lastMessageAt: _parseInstant(json['last_message_at']),
      unreadCount: json['unread_count'] as int? ?? 0,
      peerOnline: json['peer_online'] as bool? ?? false,
      peerLastSeenAt: lastSeenRaw is String
          ? DateTime.tryParse(lastSeenRaw)?.toLocal()
          : null,
    );
  }

  /// [myId] decides the "You:" prefix. A null preview means the last message
  /// was deleted; the row renders a placeholder. `lastMessageSeen` has no
  /// source in this payload, so the mini-avatar receipt stays off.
  ConversationEntity toEntity(String myId) => ConversationEntity(
        id: id,
        user: peer.toEntity(isOnline: peerOnline, lastSeenAt: peerLastSeenAt),
        preview: lastMessagePreview ?? '',
        previewKind: lastMessagePreview == null
            ? ConversationPreviewKind.deleted
            : ConversationPreviewKind.text,
        isLastMessageMine: lastMessageSenderId == myId,
        lastMessageAt: lastMessageAt,
        unreadCount: unreadCount,
      );
}

/// `GET /dms/conversations` page envelope.
class DmConversationsPageModel {
  final List<DmConversationModel> items;
  final String? nextCursor;

  const DmConversationsPageModel({required this.items, this.nextCursor});

  factory DmConversationsPageModel.fromJson(Map<String, dynamic> json) =>
      DmConversationsPageModel(
        items: [
          for (final item in json['items'] as List? ?? const [])
            if (item is Map<String, dynamic>)
              DmConversationModel.fromJson(item),
        ],
        nextCursor: json['next_cursor'] as String?,
      );
}

/// A message on the wire — REST responses and `message.created` pushes share
/// this shape.
class DmMessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final bool deleted;
  final DateTime createdAt;

  const DmMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.deleted,
    required this.createdAt,
  });

  factory DmMessageModel.fromJson(Map<String, dynamic> json) => DmMessageModel(
        id: json['id'] as String,
        conversationId: json['conversation_id'] as String? ?? '',
        senderId: json['sender_id'] as String? ?? '',
        content: json['content'] as String? ?? '',
        deleted: json['deleted'] as bool? ?? false,
        createdAt: _parseInstant(json['created_at']),
      );

  MessageEntity toEntity(String myId) => MessageEntity(
        id: id,
        isMine: senderId == myId,
        text: content,
        sentAt: createdAt,
        isDeleted: deleted,
      );
}

/// `GET /dms/conversations/{id}/messages` page envelope (items newest first
/// on the wire).
class DmMessagesPageModel {
  final List<DmMessageModel> items;
  final String? nextCursor;
  final String? peerLastReadMessageId;

  const DmMessagesPageModel({
    required this.items,
    this.nextCursor,
    this.peerLastReadMessageId,
  });

  factory DmMessagesPageModel.fromJson(Map<String, dynamic> json) =>
      DmMessagesPageModel(
        items: [
          for (final item in json['items'] as List? ?? const [])
            if (item is Map<String, dynamic>) DmMessageModel.fromJson(item),
        ],
        nextCursor: json['next_cursor'] as String?,
        peerLastReadMessageId: json['peer_last_read_message_id'] as String?,
      );
}
