import 'package:tweakd/features/forums/data/models/forum_models.dart';
import 'package:tweakd/features/posts/data/models/post_comment_models.dart';
import 'package:tweakd/features/posts/data/models/post_models.dart';

import '../../domain/entities/tagged_item.dart';

/// Wire models for `/tags/*`. The nested payloads are the exact DTOs the feed
/// and forums screens already parse, so they are decoded with those features'
/// own models instead of tag-local copies — one less place to keep in sync.
class TaggedItemModel {
  final TaggedItemEntity entity;

  const TaggedItemModel(this.entity);

  factory TaggedItemModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? obj(String key) => json[key] as Map<String, dynamic>?;

    final post = obj('post');
    final comment = obj('comment');
    final thread = obj('thread');
    final reply = obj('reply');

    return TaggedItemModel(TaggedItemEntity(
      kind: _kindFromJson(json['kind'] as String?),
      taggedAt: DateTime.parse(json['tagged_at'] as String),
      targetId: json['target_id'] as String,
      post: post == null ? null : PostModel.fromJson(post).toEntity(),
      comment:
          comment == null ? null : PostCommentModel.fromJson(comment).toEntity(),
      thread:
          thread == null ? null : ForumThreadModel.fromJson(thread).toEntity(),
      reply: reply == null ? null : ForumReplyModel.fromJson(reply).toEntity(),
    ));
  }

  TaggedItemEntity toEntity() => entity;

  /// Unknown kinds fall back to [TaggedItemKind.post]; the card layer picks its
  /// renderer from the payload that is actually present, so a future kind the
  /// app doesn't know about degrades to "nothing to render" rather than a crash.
  static TaggedItemKind _kindFromJson(String? value) => switch (value) {
        'post_comment' => TaggedItemKind.postComment,
        'forum_thread' => TaggedItemKind.forumThread,
        'forum_reply' => TaggedItemKind.forumReply,
        _ => TaggedItemKind.post,
      };
}

/// Cursor-paginated page of tagged items (`GET /tags/me`,
/// `GET /tags/by-username/{username}`).
class TaggedItemPageModel {
  final List<TaggedItemModel> items;
  final String? nextCursor;

  const TaggedItemPageModel({required this.items, this.nextCursor});

  factory TaggedItemPageModel.fromJson(Map<String, dynamic> json) {
    return TaggedItemPageModel(
      items: ((json['items'] as List<dynamic>?) ?? const [])
          .map((e) => TaggedItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
    );
  }

  TaggedItemPageEntity toEntity() => TaggedItemPageEntity(
        items: items.map((m) => m.toEntity()).toList(),
        nextCursor: nextCursor,
      );
}
