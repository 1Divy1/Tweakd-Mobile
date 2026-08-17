import 'dart:async';

import 'package:equatable/equatable.dart';

import '../../../domain/entities/feedback_sort.dart';

sealed class FeedbackBoardEvent extends Equatable {
  const FeedbackBoardEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the first page in the current sort (full-screen loading).
class LoadFeedbackBoard extends FeedbackBoardEvent {
  const LoadFeedbackBoard();
}

/// Switches the ordering. The cursor is sort-scoped, so this refetches from
/// scratch rather than paging on top of the old list.
class ChangeFeedbackSort extends FeedbackBoardEvent {
  final FeedbackSort sort;
  const ChangeFeedbackSort(this.sort);

  @override
  List<Object?> get props => [sort];
}

/// Pull-to-refresh: re-fetches the first page without tearing down the list.
/// [completer] releases the refresh indicator once the request settles, even
/// when the data is identical and no new state is emitted.
class RefreshFeedbackBoard extends FeedbackBoardEvent {
  final Completer<void>? completer;
  const RefreshFeedbackBoard([this.completer]);

  @override
  List<Object?> get props => [completer];
}

/// Fetches the next page. No-op when a page is in flight or there is no next.
class LoadMoreFeedbackBoard extends FeedbackBoardEvent {
  const LoadMoreFeedbackBoard();
}

/// Taps an arrow on a card. [value] is 1 (up) or -1 (down); tapping the arrow
/// already selected withdraws the vote.
class VoteOnFeedbackMessage extends FeedbackBoardEvent {
  final String messageId;
  final int value;

  const VoteOnFeedbackMessage({required this.messageId, required this.value});

  @override
  List<Object?> get props => [messageId, value];
}

/// Hard-deletes the viewer's own message (only allowed while it is `sent`).
class DeleteFeedbackMessage extends FeedbackBoardEvent {
  final String messageId;
  const DeleteFeedbackMessage(this.messageId);

  @override
  List<Object?> get props => [messageId];
}
