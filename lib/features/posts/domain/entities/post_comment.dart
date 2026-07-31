import 'package:equatable/equatable.dart';

import 'post_tagged_car.dart';
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

  /// Number of direct replies to this comment. Always 0 for a reply itself
  /// (replies aren't nested beyond one level). Defaults to 0 when the backend
  /// omits it.
  final int replyCount;

  /// People tagged in the comment. Empty on a soft-deleted comment, and empty
  /// on any payload from a backend that doesn't serve comment tags yet.
  final List<PostUserEntity> taggedPeople;

  /// Cars tagged in the comment — each one's owner is in [taggedPeople], except
  /// the comment author's own cars.
  final List<PostTaggedCarEntity> taggedCars;
  final DateTime createdAt;

  const PostCommentEntity({
    required this.id,
    required this.author,
    required this.content,
    required this.parentCommentId,
    required this.deleted,
    required this.likeCount,
    required this.viewerHasLiked,
    this.replyCount = 0,
    this.taggedPeople = const [],
    this.taggedCars = const [],
    required this.createdAt,
  });

  bool get isReply => parentCommentId != null;

  PostCommentEntity copyWith({
    String? content,
    bool? deleted,
    int? likeCount,
    bool? viewerHasLiked,
    int? replyCount,
    List<PostUserEntity>? taggedPeople,
    List<PostTaggedCarEntity>? taggedCars,
  }) {
    return PostCommentEntity(
      id: id,
      author: author,
      content: content ?? this.content,
      parentCommentId: parentCommentId,
      deleted: deleted ?? this.deleted,
      likeCount: likeCount ?? this.likeCount,
      viewerHasLiked: viewerHasLiked ?? this.viewerHasLiked,
      replyCount: replyCount ?? this.replyCount,
      taggedPeople: taggedPeople ?? this.taggedPeople,
      taggedCars: taggedCars ?? this.taggedCars,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        author,
        content,
        parentCommentId,
        deleted,
        likeCount,
        viewerHasLiked,
        replyCount,
        taggedPeople,
        taggedCars,
        createdAt,
      ];
}
