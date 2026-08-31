import 'package:equatable/equatable.dart';

/// The known notification kinds the backend emits. [unknown] is a forward-
/// compatible catch-all: a future/unrecognised wire value still renders with
/// its title/body but carries no navigation target.
enum NotificationType {
  postLike,
  postShare,
  postComment,
  postTag,
  postCommentTag,
  forumThreadReply,
  forumReplyReply,
  forumThreadLike,
  forumReplyLike,
  forumThreadTag,
  forumReplyTag,
  mapEventApproved,
  mapEventRejected,
  mapEventCarDecided,
  mapEventCarRegistered,
  mapEventOrganizerAdded,
  mapEventWithdrawalRequested,
  mapEventWithdrawalDecided,
  feedbackStatus,
  feedbackFeedStatusChanged,
  ticketReply,
  moderationWarning,
  contentRemoved,
  dm,
  unknown;

  /// Maps a raw wire `type` string to a [NotificationType], defaulting to
  /// [unknown] so unrecognised server values never break parsing.
  ///
  /// The set mirrors the backend's producers exactly: the `posts`, `forums`
  /// and `map_events` notification listeners, the four admin/moderation types
  /// written through `NotificationService.push`, and `dm` — which is written
  /// by Postgres and pushed by a Supabase edge function rather than Spring.
  static NotificationType fromWire(String raw) {
    switch (raw) {
      case 'post_like':
        return NotificationType.postLike;
      case 'post_share':
        return NotificationType.postShare;
      case 'post_comment':
        return NotificationType.postComment;
      case 'post_tag':
        return NotificationType.postTag;
      case 'post_comment_tag':
        return NotificationType.postCommentTag;
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
      case 'map_event_approved':
        return NotificationType.mapEventApproved;
      case 'map_event_rejected':
        return NotificationType.mapEventRejected;
      case 'map_event_car_decided':
        return NotificationType.mapEventCarDecided;
      case 'map_event_car_registered':
        return NotificationType.mapEventCarRegistered;
      case 'map_event_organizer_added':
        return NotificationType.mapEventOrganizerAdded;
      case 'map_event_withdrawal_requested':
        return NotificationType.mapEventWithdrawalRequested;
      case 'map_event_withdrawal_decided':
        return NotificationType.mapEventWithdrawalDecided;
      case 'feedback_status':
        return NotificationType.feedbackStatus;
      case 'feedback_status_changed':
        return NotificationType.feedbackFeedStatusChanged;
      case 'ticket_reply':
        return NotificationType.ticketReply;
      case 'moderation_warning':
        return NotificationType.moderationWarning;
      case 'content_removed':
        return NotificationType.contentRemoved;
      case 'dm':
        return NotificationType.dm;
      default:
        return NotificationType.unknown;
    }
  }

  /// Anything whose payload carries `post_id`.
  bool get isPost =>
      this == NotificationType.postLike ||
      this == NotificationType.postShare ||
      this == NotificationType.postComment ||
      this == NotificationType.postTag ||
      this == NotificationType.postCommentTag;

  /// Anything whose payload carries `thread_id`.
  bool get isForum =>
      this == NotificationType.forumThreadReply ||
      this == NotificationType.forumReplyReply ||
      this == NotificationType.forumThreadLike ||
      this == NotificationType.forumReplyLike ||
      this == NotificationType.forumThreadTag ||
      this == NotificationType.forumReplyTag;

  /// Anything whose payload carries `event_id`. All seven open the event —
  /// the organiser-facing ones (`car_registered`, `organizer_added`,
  /// `withdrawal_requested`) included, since the manage screen hangs off it.
  bool get isMapEvent =>
      this == NotificationType.mapEventApproved ||
      this == NotificationType.mapEventRejected ||
      this == NotificationType.mapEventCarDecided ||
      this == NotificationType.mapEventCarRegistered ||
      this == NotificationType.mapEventOrganizerAdded ||
      this == NotificationType.mapEventWithdrawalRequested ||
      this == NotificationType.mapEventWithdrawalDecided;

  /// A direct message. Unlike the others this one is written by Postgres and
  /// pushed by a Supabase edge function, so its payload has its own shape:
  /// `conversation_id`, `message_id`, `actor_id`, `actor_username`.
  bool get isDm => this == NotificationType.dm;

  /// Tag notifications, whose payload also carries `car_tagged` — a boolean
  /// picking the wording ("tagged your car" vs "tagged you"), not a car id.
  /// There is no car id on the wire, so a tag always opens the post or thread
  /// the tag was made in.
  bool get isTag =>
      this == NotificationType.postTag ||
      this == NotificationType.postCommentTag ||
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
  String? get conversationId => payload['conversation_id'];

  /// The in-app route this notification points at, or null when there is
  /// nothing to open. See [notificationRouteFor].
  String? get targetRoute => notificationRouteFor(type, payload);

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

/// Ids that are safe to interpolate into a router path.
///
/// A payload is authored by our own backend but still arrives over the network
/// — and for a push notification it arrives *before* any of it has been
/// validated. Interpolating an unchecked value into a path lets a malformed or
/// tampered id resolve to a route it was never meant to reach (`..%2Fadmin`,
/// a value with a `/` splicing on extra segments, a query string smuggling
/// `extra` state). Deliberately narrow: every id the backend issues is a UUID,
/// a numeric id or a username, and all three fit comfortably.
final _safeRouteId = RegExp(r'^[A-Za-z0-9_-]{1,64}$');

/// Returns [payload]'s value for [key] only when it is a safe route id.
String? safeRouteId(Map<String, String> payload, String key) {
  final value = payload[key];
  if (value == null || !_safeRouteId.hasMatch(value)) return null;
  return value;
}

/// The in-app route a notification of [type] with [payload] points at, or null
/// when there is nothing to open — an unknown type, or a known type whose id
/// is missing or fails [safeRouteId].
///
/// Shared by the in-app notifications list and by push notification taps so
/// both resolve identically; the DM route additionally needs a
/// `MessageUserEntity` as `extra`, which `core/push/push_navigator.dart`
/// attaches (the domain layer cannot reach across features to build one).
///
/// Comment and reply notifications carry a `comment_id` / `reply_id` too, but
/// resolve to their parent post or thread: neither detail page can scroll to
/// a child yet. The ids stay in the payload for when they can.
String? notificationRouteFor(NotificationType type, Map<String, String> payload) {
  if (type.isPost) {
    final id = safeRouteId(payload, 'post_id');
    return id == null ? null : '/posts/$id';
  }
  if (type.isForum) {
    final id = safeRouteId(payload, 'thread_id');
    return id == null ? null : '/forums/threads/$id';
  }
  if (type.isMapEvent) {
    final id = safeRouteId(payload, 'event_id');
    return id == null ? null : '/map-events/$id';
  }
  if (type.isDm) {
    final id = safeRouteId(payload, 'conversation_id');
    // No conversation id still opens the inbox — a DM notification the user
    // taps should never dead-end.
    return id == null ? '/messages' : '/messages/$id';
  }
  switch (type) {
    // No per-item screens exist for these, so they open the list that
    // contains the item. Two separate surfaces: `feedback_status` is the
    // user's own submitted feedback (the `feedback` module), while
    // `feedback_status_changed` is a Postgres trigger on the community board
    // (the `feedbackfeed` module) — different tables, different screens.
    case NotificationType.feedbackStatus:
      return '/feedback/mine';
    case NotificationType.feedbackFeedStatusChanged:
      return '/feedback-feed';
    case NotificationType.ticketReply:
      return '/reports';

    // A warning leaves the content in place, so `target_id` is routable —
    // `target_type` says which screen it belongs to. `comment` and
    // `forum_thread_reply` name a child whose parent isn't in the payload,
    // and neither detail page opens on a child, so those stay unrouted.
    case NotificationType.moderationWarning:
      final targetId = safeRouteId(payload, 'target_id');
      if (targetId == null) return null;
      return switch (payload['target_type']) {
        'post' => '/posts/$targetId',
        'forum_thread' => '/forums/threads/$targetId',
        _ => null,
      };

    // Deliberately unrouted: the backend deletes the content immediately
    // before sending this, so `target_id` names a row that 404s.
    case NotificationType.contentRemoved:
      return null;

    default:
      return null;
  }
}
