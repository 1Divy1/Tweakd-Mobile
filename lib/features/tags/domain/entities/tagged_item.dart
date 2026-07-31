import 'package:equatable/equatable.dart';

import 'package:car_social_media_app/features/forums/domain/entities/forum_reply.dart';
import 'package:car_social_media_app/features/forums/domain/entities/forum_thread.dart';
import 'package:car_social_media_app/features/posts/domain/entities/post.dart';
import 'package:car_social_media_app/features/posts/domain/entities/post_comment.dart';

/// The four kinds of content a person (or their car) can be tagged in. DMs are
/// deliberately absent — private conversations never surface in the tags feed.
enum TaggedItemKind { post, postComment, forumThread, forumReply }

/// Wire value used both by `kind` on the feed items and by the `{kind}` path
/// segment of `DELETE /tags/{kind}/{targetId}`.
extension TaggedItemKindApi on TaggedItemKind {
  String get apiValue => switch (this) {
        TaggedItemKind.post => 'post',
        TaggedItemKind.postComment => 'post_comment',
        TaggedItemKind.forumThread => 'forum_thread',
        TaggedItemKind.forumReply => 'forum_reply',
      };
}

/// One row of the tags feed: a merged read across posts, post comments, forum
/// threads and forum replies.
///
/// Which payload is set depends on [kind] — the backend omits the rest:
///
/// | kind          | populated                      |
/// |---------------|--------------------------------|
/// | post          | [post]                         |
/// | postComment   | [post] (the parent), [comment] |
/// | forumThread   | [thread]                       |
/// | forumReply    | [thread] (the parent), [reply] |
///
/// [taggedAt] is when the tag was made, not when the content was created, and
/// it is the feed's sort key — a fresh tag on an old post jumps to the top.
/// [targetId] is what the untag endpoint takes.
class TaggedItemEntity extends Equatable {
  final TaggedItemKind kind;
  final DateTime taggedAt;
  final String targetId;
  final PostEntity? post;
  final PostCommentEntity? comment;
  final ForumThreadEntity? thread;
  final ForumReplyEntity? reply;

  const TaggedItemEntity({
    required this.kind,
    required this.taggedAt,
    required this.targetId,
    this.post,
    this.comment,
    this.thread,
    this.reply,
  });

  /// Feed rows are already deduped server-side per (kind, target), so this is
  /// a stable identity for list keys and optimistic removal.
  String get id => '${kind.apiValue}:$targetId';

  @override
  List<Object?> get props => [kind, taggedAt, targetId, post, comment, thread, reply];
}

/// Cursor-paginated page of tagged items. [nextCursor] being null is the *only*
/// end-of-feed signal: a page can come back shorter than the requested size and
/// still have more data behind it, because dedup happens after the four streams
/// are merged.
class TaggedItemPageEntity extends Equatable {
  final List<TaggedItemEntity> items;
  final String? nextCursor;

  const TaggedItemPageEntity({required this.items, this.nextCursor});

  @override
  List<Object?> get props => [items, nextCursor];
}
