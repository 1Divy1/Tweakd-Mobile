import 'package:equatable/equatable.dart';

import 'post_user.dart';

/// A comment on a post. Soft-deleted comments are kept to anchor replies:
/// [deleted] is true and [content] is null in that case. [parentCommentId] is
/// null for top-level comments and set for replies.
class PostCommentEntity extends Equatable {
  final String id;
  final PostUserEntity author;
  final String? content;
  final String? parentCommentId;
  final bool deleted;
  final int likeCount;
  final bool viewerHasLiked;
  final DateTime createdAt;

  const PostCommentEntity({
    required this.id,
    required this.author,
    required this.content,
    required this.parentCommentId,
    required this.deleted,
    required this.likeCount,
    required this.viewerHasLiked,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        author,
        content,
        parentCommentId,
        deleted,
        likeCount,
        viewerHasLiked,
        createdAt,
      ];
}
