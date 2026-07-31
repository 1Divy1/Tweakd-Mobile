import 'package:equatable/equatable.dart';

import '../../../domain/entities/tagged_item.dart';

sealed class TagsEvent extends Equatable {
  const TagsEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the first page. [username] null means the signed-in user's own feed
/// (`/tags/me`). The bloc remembers it for later pages and refreshes.
///
/// Dispatched lazily — the profile only fires this the first time the Tags tab
/// is opened, so visiting a profile doesn't pay for the merged query.
class LoadTags extends TagsEvent {
  final String? username;
  const LoadTags({this.username});

  @override
  List<Object?> get props => [username];
}

/// Pull-to-refresh: re-fetches the first page without tearing down the list.
class RefreshTags extends TagsEvent {
  const RefreshTags();
}

/// Fetches the next page using the held cursor. No-op when there is no next
/// page or a page is already in flight.
class LoadMoreTags extends TagsEvent {
  const LoadMoreTags();
}

/// Untags the signed-in user from [item] (own feed only).
class RemoveTagFromItem extends TagsEvent {
  final TaggedItemEntity item;
  const RemoveTagFromItem(this.item);

  @override
  List<Object?> get props => [item];
}

/// Clears the one-shot remove failure after the UI has shown it.
class ClearTagRemoveError extends TagsEvent {
  const ClearTagRemoveError();
}
