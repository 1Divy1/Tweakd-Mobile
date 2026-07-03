import 'package:equatable/equatable.dart';

sealed class ForumThreadEvent extends Equatable {
  const ForumThreadEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the thread detail, then its first page of top-level replies.
class LoadForumThread extends ForumThreadEvent {
  final String threadId;
  const LoadForumThread(this.threadId);

  @override
  List<Object?> get props => [threadId];
}

/// Next page of top-level replies.
class LoadMoreThreadReplies extends ForumThreadEvent {
  const LoadMoreThreadReplies();
}

/// Expands a reply's children (fetching the first page on first expand) or
/// collapses them if already expanded.
class ToggleReplyChildren extends ForumThreadEvent {
  final String postId;
  const ToggleReplyChildren(this.postId);

  @override
  List<Object?> get props => [postId];
}

/// Next page of one reply's children.
class LoadMoreReplyChildren extends ForumThreadEvent {
  final String postId;
  const LoadMoreReplyChildren(this.postId);

  @override
  List<Object?> get props => [postId];
}

/// Optimistically toggles the viewer's like on the thread.
class ToggleForumThreadLike extends ForumThreadEvent {
  const ToggleForumThreadLike();
}

/// Optimistically toggles the viewer's like on one reply.
class ToggleForumReplyLike extends ForumThreadEvent {
  final String postId;
  const ToggleForumReplyLike(this.postId);

  @override
  List<Object?> get props => [postId];
}

/// Targets the composer at a reply ([postId] null = top-level).
class StartReplyTo extends ForumThreadEvent {
  final String? postId;
  final String? username;
  const StartReplyTo({this.postId, this.username});

  @override
  List<Object?> get props => [postId, username];
}

/// Sends the composer's content to the current reply target.
class SubmitForumReply extends ForumThreadEvent {
  final String content;
  const SubmitForumReply(this.content);

  @override
  List<Object?> get props => [content];
}

/// Author-only: replaces the OP body.
class EditForumThreadBody extends ForumThreadEvent {
  final String content;
  const EditForumThreadBody(this.content);

  @override
  List<Object?> get props => [content];
}

/// Author-only: deletes the thread (anonymized if it has replies).
class DeleteForumThreadRequested extends ForumThreadEvent {
  const DeleteForumThreadRequested();
}

/// Author-only: replaces one reply's content.
class EditForumReplyBody extends ForumThreadEvent {
  final String postId;
  final String content;
  const EditForumReplyBody(this.postId, this.content);

  @override
  List<Object?> get props => [postId, content];
}

/// Author-only: deletes one reply ("[deleted]" placeholder if it has
/// children, gone otherwise).
class DeleteForumReplyRequested extends ForumThreadEvent {
  final String postId;
  const DeleteForumReplyRequested(this.postId);

  @override
  List<Object?> get props => [postId];
}
