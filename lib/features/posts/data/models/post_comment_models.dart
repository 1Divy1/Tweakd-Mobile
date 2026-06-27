import '../../domain/entities/post_comment.dart';
import '../../domain/entities/post_pages.dart';
import 'post_models.dart';

class PostCommentModel {
  final String id;
  final PostUserModel author;
  final String? content;
  final String? parentCommentId;
  final bool deleted;
  final int likeCount;
  final bool viewerHasLiked;
  final DateTime createdAt;

  const PostCommentModel({
    required this.id,
    required this.author,
    required this.content,
    required this.parentCommentId,
    required this.deleted,
    required this.likeCount,
    required this.viewerHasLiked,
    required this.createdAt,
  });

  factory PostCommentModel.fromJson(Map<String, dynamic> json) {
    return PostCommentModel(
      id: json['id'] as String,
      author: PostUserModel.fromJson(json['author'] as Map<String, dynamic>),
      content: json['content'] as String?,
      parentCommentId: json['parent_comment_id'] as String?,
      deleted: json['deleted'] as bool? ?? false,
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      viewerHasLiked: json['viewer_has_liked'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  PostCommentEntity toEntity() => PostCommentEntity(
        id: id,
        author: author.toEntity(),
        content: content,
        parentCommentId: parentCommentId,
        deleted: deleted,
        likeCount: likeCount,
        viewerHasLiked: viewerHasLiked,
        createdAt: createdAt,
      );
}

/// Cursor-paginated page of comments (GET /posts/{id}/comments).
class CommentPageModel {
  final List<PostCommentModel> items;
  final String? nextCursor;

  const CommentPageModel({required this.items, required this.nextCursor});

  factory CommentPageModel.fromJson(Map<String, dynamic> json) {
    return CommentPageModel(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => PostCommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
    );
  }

  CommentPageEntity toEntity() => CommentPageEntity(
        items: items.map((c) => c.toEntity()).toList(),
        nextCursor: nextCursor,
      );
}

/// Cursor-paginated page of likers (GET /posts/{id}/likes). Items reuse the
/// shared [PostUserModel] shape.
class LikerPageModel {
  final List<PostUserModel> items;
  final String? nextCursor;

  const LikerPageModel({required this.items, required this.nextCursor});

  factory LikerPageModel.fromJson(Map<String, dynamic> json) {
    return LikerPageModel(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => PostUserModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
    );
  }

  LikerPageEntity toEntity() => LikerPageEntity(
        items: items.map((u) => u.toEntity()).toList(),
        nextCursor: nextCursor,
      );
}
