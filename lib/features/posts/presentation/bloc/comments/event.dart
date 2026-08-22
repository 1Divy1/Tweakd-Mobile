import 'package:equatable/equatable.dart';

import 'package:tweakd/core/shared/entities/tag_selection.dart';

sealed class CommentsEvent extends Equatable {
  const CommentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadComments extends CommentsEvent {
  final String postId;

  /// The post's comment count, used to seed the running total shown in the
  /// sheet header before the first page resolves.
  final int initialCount;
  const LoadComments(this.postId, {this.initialCount = 0});

  @override
  List<Object?> get props => [postId, initialCount];
}

class LoadMoreComments extends CommentsEvent {
  const LoadMoreComments();
}

class SubmitComment extends CommentsEvent {
  final String content;
  const SubmitComment(this.content);

  @override
  List<Object?> get props => [content];
}

/// Posts a reply to [parentCommentId]. The thread is auto-expanded so the new
/// reply is visible.
class SubmitReply extends CommentsEvent {
  final String parentCommentId;
  final String content;
  const SubmitReply({required this.parentCommentId, required this.content});

  @override
  List<Object?> get props => [parentCommentId, content];
}

/// Expands or collapses a root comment's reply thread, lazily loading the first
/// page the first time it's opened.
class ToggleReplies extends CommentsEvent {
  final String commentId;
  const ToggleReplies(this.commentId);

  @override
  List<Object?> get props => [commentId];
}

/// Fetches the next page of replies for [commentId].
class LoadMoreReplies extends CommentsEvent {
  final String commentId;
  const LoadMoreReplies(this.commentId);

  @override
  List<Object?> get props => [commentId];
}

class RemoveComment extends CommentsEvent {
  final String commentId;
  const RemoveComment(this.commentId);

  @override
  List<Object?> get props => [commentId];
}

/// Hides a comment from the viewer's list after they report it. Local only — the
/// comment is not deleted on the backend, just removed from this session's view.
class HideComment extends CommentsEvent {
  final String commentId;
  const HideComment(this.commentId);

  @override
  List<Object?> get props => [commentId];
}

class ToggleCommentLike extends CommentsEvent {
  final String commentId;
  const ToggleCommentLike(this.commentId);

  @override
  List<Object?> get props => [commentId];
}

// ── Pending tag selection ──────────────────────────────────────────────────
// The selection for the comment being composed lives in the bloc (not in the
// sheet's local state) so it survives the tag sheet closing and is sent along
// with the comment, mirroring the forum reply composer.

class AddCommentTagPerson extends CommentsEvent {
  final TaggedPerson person;
  const AddCommentTagPerson(this.person);

  @override
  List<Object?> get props => [person.id];
}

/// Removes a person and, with them, any of their cars — the backend rejects a
/// car whose owner isn't tagged.
class RemoveCommentTagPerson extends CommentsEvent {
  final String personId;
  const RemoveCommentTagPerson(this.personId);

  @override
  List<Object?> get props => [personId];
}

class AddCommentTagCar extends CommentsEvent {
  final TaggedCar car;
  const AddCommentTagCar(this.car);

  @override
  List<Object?> get props => [car.id];
}

class RemoveCommentTagCar extends CommentsEvent {
  final String carId;
  const RemoveCommentTagCar(this.carId);

  @override
  List<Object?> get props => [carId];
}
