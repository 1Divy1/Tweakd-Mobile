import 'dart:async';

import 'package:equatable/equatable.dart';

sealed class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the first page of the global feed (full-screen loading).
class LoadFeed extends FeedEvent {
  const LoadFeed();
}

/// Pull-to-refresh: re-fetches the first page without tearing down the list.
/// [completer], when provided, is completed once the refresh settles so the
/// pull-to-refresh indicator can stop — even when the data is unchanged and no
/// new state is emitted.
class RefreshFeed extends FeedEvent {
  final Completer<void>? completer;
  const RefreshFeed([this.completer]);

  @override
  List<Object?> get props => [completer];
}

/// Fetches the next page using the held cursor. No-op when there is no next
/// page or a page is already in flight.
class LoadMoreFeed extends FeedEvent {
  const LoadMoreFeed();
}

/// Optimistically toggles the viewer's like on a single feed post.
class ToggleLikeFeedPost extends FeedEvent {
  final String postId;
  const ToggleLikeFeedPost(this.postId);

  @override
  List<Object?> get props => [postId];
}

/// Optimistically toggles the viewer's save (bookmark) on a single feed post.
class ToggleSaveFeedPost extends FeedEvent {
  final String postId;
  const ToggleSaveFeedPost(this.postId);

  @override
  List<Object?> get props => [postId];
}

/// Optimistically toggles the viewer's repost of a single feed post.
class ToggleRepostFeedPost extends FeedEvent {
  final String postId;
  const ToggleRepostFeedPost(this.postId);

  @override
  List<Object?> get props => [postId];
}

/// Sets a feed post's comment count to [count]. Forwarded by the comments sheet
/// so the feed card's counter stays in sync with adds/deletes.
class UpdateFeedPostCommentCount extends FeedEvent {
  final String postId;
  final int count;
  const UpdateFeedPostCommentCount(this.postId, this.count);

  @override
  List<Object?> get props => [postId, count];
}

/// Posts a root comment on a feed post from the card's inline composer,
/// optimistically bumping the comment counter (reverted on failure).
class SubmitFeedComment extends FeedEvent {
  final String postId;
  final String content;
  const SubmitFeedComment(this.postId, this.content);

  @override
  List<Object?> get props => [postId, content];
}

/// Removes a post from the feed after the viewer reports it, so the next post
/// takes its place. The post is only hidden from the UI, never deleted.
class HideFeedPost extends FeedEvent {
  final String postId;
  const HideFeedPost(this.postId);

  @override
  List<Object?> get props => [postId];
}
