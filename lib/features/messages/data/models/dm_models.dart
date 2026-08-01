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

  MessageUserEntity toEntity({bool isOnline = false}) => MessageUserEntity(
        id: id,
        username: username,
        avatarUrl: avatarUrl,
        isOnline: isOnline,
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

  const DmConversationModel({
    required this.id,
    required this.peer,
    this.lastMessagePreview,
    this.lastMessageSenderId,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  /// The payload still carries `peer_online` / `peer_last_seen_at` from the
  /// Spring presence this build replaced. Both are ignored: online state now
  /// comes from the Supabase presence channel.
  factory DmConversationModel.fromJson(Map<String, dynamic> json) =>
      DmConversationModel(
        id: json['id'] as String,
        peer: DmPeerModel.fromJson(json['peer'] as Map<String, dynamic>),
        lastMessagePreview: json['last_message_preview'] as String?,
        lastMessageSenderId: json['last_message_sender_id'] as String?,
        lastMessageAt: _parseInstant(json['last_message_at']),
        unreadCount: json['unread_count'] as int? ?? 0,
      );

  /// [myId] decides the "You:" prefix. A null preview means the last message
  /// was deleted; the row renders a placeholder. `lastMessageSeen` has no
  /// source in this payload, so the mini-avatar receipt stays off.
  ConversationEntity toEntity(String myId, {bool isPeerOnline = false}) =>
      ConversationEntity(
        id: id,
        user: peer.toEntity(isOnline: isPeerOnline),
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

/// A car shared into a DM, from `tagged_cars[]` on a message. Same sub-shapes
/// as the garage endpoints (`cover_image {key, url}`); parsed defensively so a
/// missing cover or malformed entry never breaks a message.
class DmTaggedCarModel {
  final String id;
  final String brand;
  final String model;
  final String? coverImageUrl;

  const DmTaggedCarModel({
    required this.id,
    required this.brand,
    required this.model,
    this.coverImageUrl,
  });

  factory DmTaggedCarModel.fromJson(Map<String, dynamic> json) {
    final cover = json['cover_image'];
    return DmTaggedCarModel(
      id: json['id'] as String,
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      coverImageUrl:
          cover is Map<String, dynamic> ? cover['url'] as String? : null,
    );
  }

  DmTaggedCarEntity toEntity() => DmTaggedCarEntity(
        id: id,
        brand: brand,
        model: model,
        coverImageUrl: coverImageUrl,
      );

  /// Mirror of [fromJson] for the realtime broadcast the sender publishes —
  /// the peer parses it back with the very same factory.
  Map<String, dynamic> toJson() => {
        'id': id,
        'brand': brand,
        'model': model,
        'cover_image': {'url': ?coverImageUrl},
      };

  factory DmTaggedCarModel.fromEntity(DmTaggedCarEntity car) =>
      DmTaggedCarModel(
        id: car.id,
        brand: car.brand,
        model: car.model,
        coverImageUrl: car.coverImageUrl,
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
  final List<DmTaggedCarModel> taggedCars;
  final DateTime createdAt;

  const DmMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.deleted,
    this.taggedCars = const [],
    required this.createdAt,
  });

  factory DmMessageModel.fromJson(Map<String, dynamic> json) => DmMessageModel(
        id: json['id'] as String,
        conversationId: json['conversation_id'] as String? ?? '',
        senderId: json['sender_id'] as String? ?? '',
        content: json['content'] as String? ?? '',
        deleted: json['deleted'] as bool? ?? false,
        taggedCars: [
          for (final car in json['tagged_cars'] as List? ?? const [])
            if (car is Map<String, dynamic>) DmTaggedCarModel.fromJson(car),
        ],
        createdAt: _parseInstant(json['created_at']),
      );

  MessageEntity toEntity(String myId) => MessageEntity(
        id: id,
        isMine: senderId == myId,
        text: content,
        taggedCars: [for (final car in taggedCars) car.toEntity()],
        sentAt: createdAt,
        isDeleted: deleted,
      );

  /// The `dm_send_message` RPC cannot return `tagged_cars` (cover-image URLs
  /// are built from R2 keys by Spring), so the sender stitches back the cars
  /// it picked in the composer.
  DmMessageModel withTaggedCars(List<DmTaggedCarModel> cars) => DmMessageModel(
        id: id,
        conversationId: conversationId,
        senderId: senderId,
        content: content,
        deleted: deleted,
        taggedCars: cars,
        createdAt: createdAt,
      );

  /// The wire shape the sender broadcasts to the peer — identical to a REST
  /// message, so [fromJson] round-trips it. Car chips travel hydrated here
  /// precisely because the database could not produce them.
  Map<String, dynamic> toJson() => {
        'id': id,
        'conversation_id': conversationId,
        'sender_id': senderId,
        'content': content,
        'deleted': deleted,
        'tagged_cars': [for (final car in taggedCars) car.toJson()],
        'created_at': createdAt.toUtc().toIso8601String(),
      };
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
