import 'dart:async';

import 'package:equatable/equatable.dart';

sealed class CompletedFeedbackEvent extends Equatable {
  const CompletedFeedbackEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the first page of shipped requests.
class LoadCompletedFeedback extends CompletedFeedbackEvent {
  const LoadCompletedFeedback();
}

/// Pull-to-refresh. [completer] releases the indicator once the request
/// settles, even when nothing changed.
class RefreshCompletedFeedback extends CompletedFeedbackEvent {
  final Completer<void>? completer;
  const RefreshCompletedFeedback([this.completer]);

  @override
  List<Object?> get props => [completer];
}

/// Fetches the next page. No-op when a page is in flight or there is no next.
class LoadMoreCompletedFeedback extends CompletedFeedbackEvent {
  const LoadMoreCompletedFeedback();
}
