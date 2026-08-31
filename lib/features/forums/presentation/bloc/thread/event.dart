import 'package:equatable/equatable.dart';

import 'package:tweakd/core/shared/entities/tag_selection.dart';

import '../../../domain/entities/forum_reply.dart';

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

/// Optimistically toggles the viewer's save (bookmark) on the thread.
class ToggleForumThreadSave extends ForumThreadEvent {
  const ToggleForumThreadSave();
}

/// Switches the reply order (oldest/newest) and reloads the reply tree.
class ChangeReplySort extends ForumThreadEvent {
  final ForumReplySort sort;
  const ChangeReplySort(this.sort);

  @override
  List<Object?> get props => [sort];
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

/// Mentions a person in the reply being composed (capped at 30).
class AddReplyTagPerson extends ForumThreadEvent {
  final TaggedPerson person;
  const AddReplyTagPerson(this.person);

  @override
  List<Object?> get props => [person.id];
}

/// Un-mentions a person, dropping their cars with them (own cars stay).
class RemoveReplyTagPerson extends ForumThreadEvent {
  final String personId;
  const RemoveReplyTagPerson(this.personId);

  @override
  List<Object?> get props => [personId];
}

/// Tags a car on the reply being composed.
class AddReplyTagCar extends ForumThreadEvent {
  final TaggedCar car;
  const AddReplyTagCar(this.car);

  @override
  List<Object?> get props => [car.id];
}

/// Removes one tagged car from the reply being composed.
class RemoveReplyTagCar extends ForumThreadEvent {
  final String carId;
  const RemoveReplyTagCar(this.carId);

  @override
  List<Object?> get props => [carId];
}

/// Sends the composer's content to the current reply target.
class SubmitForumReply extends ForumThreadEvent {
  final String content;
  const SubmitForumReply(this.content);

  @override
  List<Object?> get props => [content];
}

/// Author-only: replaces the OP body and its tag sets. A null tag list leaves
/// that set unchanged; an empty one clears it.
class EditForumThreadBody extends ForumThreadEvent {
  final String content;
  final List<String>? taggedPeople;
  final List<String>? taggedCars;

  const EditForumThreadBody(this.content, {this.taggedPeople, this.taggedCars});

  @override
  List<Object?> get props => [content, taggedPeople, taggedCars];
}

/// Author-only: deletes the thread (anonymized if it has replies).
class DeleteForumThreadRequested extends ForumThreadEvent {
  const DeleteForumThreadRequested();
}

/// Author-only: replaces one reply's content and its tag sets (same null /
/// empty semantics as [EditForumThreadBody]).
class EditForumReplyBody extends ForumThreadEvent {
  final String postId;
  final String content;
  final List<String>? taggedPeople;
  final List<String>? taggedCars;

  const EditForumReplyBody(
    this.postId,
    this.content, {
    this.taggedPeople,
    this.taggedCars,
  });

  @override
  List<Object?> get props => [postId, content, taggedPeople, taggedCars];
}

/// Author-only: deletes one reply ("[deleted]" placeholder if it has
/// children, gone otherwise).
class DeleteForumReplyRequested extends ForumThreadEvent {
  final String postId;
  const DeleteForumReplyRequested(this.postId);

  @override
  List<Object?> get props => [postId];
}
