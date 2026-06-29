import 'package:equatable/equatable.dart';

import 'post.dart';
import 'post_comment.dart';
import 'post_user.dart';

/// A cursor-paginated slice of posts. [nextCursor] is an opaque string passed
/// back to fetch the next page, or null when the last page has been reached.
class PostPageEntity extends Equatable {
  final List<PostEntity> items;
  final String? nextCursor;

  const PostPageEntity({required this.items, required this.nextCursor});

  @override
  List<Object?> get props => [items, nextCursor];
}

/// A cursor-paginated slice of a post's comments.
class CommentPageEntity extends Equatable {
  final List<PostCommentEntity> items;
  final String? nextCursor;

  const CommentPageEntity({required this.items, required this.nextCursor});

  @override
  List<Object?> get props => [items, nextCursor];
}

/// A cursor-paginated slice of a post's likers.
class LikerPageEntity extends Equatable {
  final List<PostUserEntity> items;
  final String? nextCursor;

  const LikerPageEntity({required this.items, required this.nextCursor});

  @override
  List<Object?> get props => [items, nextCursor];
}
