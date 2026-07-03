import 'package:equatable/equatable.dart';

import 'forum_author.dart';

/// A reply ("post") in a thread. Replies load level by level: [replyCount] is
/// the number of direct children, fetched on demand. A [deleted] reply has a
/// null author/content and renders a "[deleted]" placeholder — it stays
/// expandable but can't be liked, replied to, or edited.
class ForumReplyEntity extends Equatable {
  final String id;
  final ForumAuthorEntity? author;
  final String? content;
  final int likesCount;
  final int replyCount;
  final bool deleted;
  final bool viewerHasLiked;
  final DateTime createdAt;

  const ForumReplyEntity({
    required this.id,
    this.author,
    this.content,
    this.likesCount = 0,
    this.replyCount = 0,
    this.deleted = false,
    this.viewerHasLiked = false,
    required this.createdAt,
  });

  ForumReplyEntity copyWith({
    String? content,
    int? likesCount,
    int? replyCount,
    bool? viewerHasLiked,
  }) {
    return ForumReplyEntity(
      id: id,
      author: author,
      content: content ?? this.content,
      likesCount: likesCount ?? this.likesCount,
      replyCount: replyCount ?? this.replyCount,
      deleted: deleted,
      viewerHasLiked: viewerHasLiked ?? this.viewerHasLiked,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        author,
        content,
        likesCount,
        replyCount,
        deleted,
        viewerHasLiked,
        createdAt,
      ];
}
