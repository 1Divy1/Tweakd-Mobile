import 'package:equatable/equatable.dart';

sealed class ProfilePostsEvent extends Equatable {
  const ProfilePostsEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the signed-in user's own posts (the Posts tab on the own profile).
class LoadMyPosts extends ProfilePostsEvent {
  const LoadMyPosts();
}

/// Loads another user's posts by username (the Posts tab on a public profile).
class LoadPostsByUsername extends ProfilePostsEvent {
  final String username;
  const LoadPostsByUsername(this.username);

  @override
  List<Object?> get props => [username];
}

/// Fetches the next page using the held cursor. No-op when there is no next
/// page or a page is already in flight.
class LoadMorePosts extends ProfilePostsEvent {
  const LoadMorePosts();
}

/// Re-runs the last load (own posts or by-username) from the first page — used
/// to reflect a post that was edited or deleted on the detail screen.
class ReloadPosts extends ProfilePostsEvent {
  const ReloadPosts();
}
