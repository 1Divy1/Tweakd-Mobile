import 'dart:async';

import 'package:equatable/equatable.dart';

sealed class SavedPostsEvent extends Equatable {
  const SavedPostsEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the first page of saved posts (full-screen loading).
class LoadSavedPosts extends SavedPostsEvent {
  const LoadSavedPosts();
}

/// Pull-to-refresh: re-fetches the first page without tearing down the grid.
/// [completer], when provided, is completed once the refresh settles so the
/// indicator can stop even when the data is unchanged and no state is emitted.
class RefreshSavedPosts extends SavedPostsEvent {
  final Completer<void>? completer;
  const RefreshSavedPosts([this.completer]);

  @override
  List<Object?> get props => [completer];
}

/// Fetches the next page using the held cursor. No-op when there is no next
/// page or a page is already in flight. A failed load-more keeps the grid.
class LoadMoreSavedPosts extends SavedPostsEvent {
  const LoadMoreSavedPosts();
}
