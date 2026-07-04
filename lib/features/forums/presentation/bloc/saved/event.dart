import 'dart:async';

import 'package:equatable/equatable.dart';

sealed class SavedThreadsEvent extends Equatable {
  const SavedThreadsEvent();

  @override
  List<Object?> get props => [];
}

/// First load of the viewer's saved threads.
class LoadSavedThreads extends SavedThreadsEvent {
  const LoadSavedThreads();
}

/// Pull-to-refresh; [completer] settles when the refresh finishes.
class RefreshSavedThreads extends SavedThreadsEvent {
  final Completer<void>? completer;
  const RefreshSavedThreads([this.completer]);

  @override
  List<Object?> get props => [completer];
}

/// Next page. No-op while loading or on the last page.
class LoadMoreSavedThreads extends SavedThreadsEvent {
  const LoadMoreSavedThreads();
}

/// Unsaves a thread, dropping it from the list (it no longer belongs here).
class UnsaveSavedThread extends SavedThreadsEvent {
  final String threadId;
  const UnsaveSavedThread(this.threadId);

  @override
  List<Object?> get props => [threadId];
}
