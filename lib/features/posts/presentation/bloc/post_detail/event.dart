import 'package:equatable/equatable.dart';

import '../../../domain/entities/post.dart';

sealed class PostDetailEvent extends Equatable {
  const PostDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadPost extends PostDetailEvent {
  final String postId;
  const LoadPost(this.postId);

  @override
  List<Object?> get props => [postId];
}

/// Optimistically toggles the viewer's like and reconciles with the backend.
class ToggleLikePost extends PostDetailEvent {
  const ToggleLikePost();
}

/// Optimistically toggles the viewer's save (bookmark).
class ToggleSavePost extends PostDetailEvent {
  const ToggleSavePost();
}

/// Optimistically toggles the viewer's repost.
class ToggleRepostPost extends PostDetailEvent {
  const ToggleRepostPost();
}

class DeletePostPressed extends PostDetailEvent {
  const DeletePostPressed();
}

/// Replaces the held post with an updated copy (e.g. after the edit screen
/// returns) without a network round-trip.
class PostUpdated extends PostDetailEvent {
  final PostEntity post;
  const PostUpdated(this.post);

  @override
  List<Object?> get props => [post];
}

/// Sets the post's comment count to [count]. Forwarded by the comments sheet so
/// the detail view's counter stays in sync with adds/deletes.
class CommentCountChanged extends PostDetailEvent {
  final int count;
  const CommentCountChanged(this.count);

  @override
  List<Object?> get props => [count];
}
