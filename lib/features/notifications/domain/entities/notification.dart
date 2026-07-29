import 'package:equatable/equatable.dart';

/// The known notification kinds the backend emits. [unknown] is a forward-
/// compatible catch-all: a future/unrecognised wire value still renders with
/// its title/body but carries no navigation target.
enum NotificationType {
  postLike,
  postShare,
  postComment,
  forumThreadReply,
  forumReplyReply,
  forumThreadLike,
  forumReplyLike,
  forumThreadTag,
  forumReplyTag,
  unknown;

  /// Maps a raw wire `type` string to a [NotificationType], defaulting to
  /// [unknown] so unrecognised server values never break parsing.
  static NotificationType fromWire(String raw) {
    switch (raw) {
      case 'post_like':
        return NotificationType.postLike;
      case 'post_share':
        return NotificationType.postShare;
      case 'post_comment':
        return NotificationType.postComment;
      case 'forum_thread_reply':
        return NotificationType.forumThreadReply;
      case 'forum_reply_reply':
        return NotificationType.forumReplyReply;
      case 'forum_thread_like':
        return NotificationType.forumThreadLike;
      case 'forum_reply_like':
        return NotificationType.forumReplyLike;
      case 'forum_thread_tag':
        return NotificationType.forumThreadTag;
      case 'forum_reply_tag':
        return NotificationType.forumReplyTag;
      default:
        return NotificationType.unknown;
    }
  }

  bool get isPost =>
      this == NotificationType.postLike ||
      this == NotificationType.postShare ||
      this == NotificationType.postComment;

  bool get isForum =>
      this == NotificationType.forumThreadReply ||
      this == NotificationType.forumReplyReply ||
      this == NotificationType.forumThreadLike ||
      this == NotificationType.forumReplyLike ||
      this == NotificationType.forumThreadTag ||
      this == NotificationType.forumReplyTag;

  /// Tag notifications, whose payload also carries `car_tagged`.
  bool get isTag =>
      this == NotificationType.forumThreadTag ||
      this == NotificationType.forumReplyTag;
}

/// A single notification. The typed [type] drives the leading icon and tap
/// navigation, while [rawType] and [payload] (all-string values) are kept so
/// unknown kinds stay renderable and future payload keys stay reachable.
class NotificationEntity extends Equatable {
  final String id;
  final NotificationType type;
  final String rawType;
  final String title;
  final String? body;
  final Map<String, String> payload;
  final bool read;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.rawType,
    required this.title,
    required this.body,
    required this.payload,
    required this.read,
    required this.createdAt,
  });

  String? get postId => payload['post_id'];
  String? get threadId => payload['thread_id'];

  /// The in-app route this notification points at, or null when there is
  /// nothing to open (unknown types, or a known type missing its id). Post
  /// types open the post detail; forum types open the thread.
  String? get targetRoute {
    if (type.isPost) {
      final id = postId;
      return id == null ? null : '/posts/$id';
    }
    if (type.isForum) {
      final id = threadId;
      return id == null ? null : '/forums/threads/$id';
    }
    return null;
  }

  NotificationEntity copyWith({bool? read}) {
    return NotificationEntity(
      id: id,
      type: type,
      rawType: rawType,
      title: title,
      body: body,
      payload: payload,
      read: read ?? this.read,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, type, rawType, title, body, payload, read, createdAt];
}

/// One cursor page of notifications. [nextCursor] is null on the last page.
class NotificationPageEntity extends Equatable {
  final List<NotificationEntity> items;
  final String? nextCursor;

  const NotificationPageEntity({required this.items, required this.nextCursor});

  @override
  List<Object?> get props => [items, nextCursor];
}
