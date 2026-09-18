import 'package:equatable/equatable.dart';

import '../../../../badges/domain/entities/user_badge.dart';
import '../../../../posts/domain/entities/post.dart';
import '../../../domain/entities/feed_page.dart';
import '../../utils/feed_error_mapper.dart';

sealed class FeedState extends Equatable {
  const FeedState();

  @override
  List<Object?> get props => [];
}

class FeedInitial extends FeedState {
  const FeedInitial();
}

class FeedLoading extends FeedState {
  const FeedLoading();
}

/// The loaded feed. [nextCursor] is null on the last page; [isLoadingMore]
/// guards the footer loader against duplicate fetches.
///
/// [pendingBadgeCelebrations] is a one-shot payload: it is set only by the
/// first page of the initial [LoadFeed] and is deliberately dropped by
/// [copyWith] and never carried by refresh or paging, so the celebration
/// overlay consumes it once per launch.
///
/// A launch opens on the page saved last time ([isCached]) while the fresh one
/// loads ([isRefreshing]). When it lands it replaces the cached posts in place
/// — unless the user has already started scrolling them, in which case it waits
/// in [newPage] behind the "New posts" pill rather than moving the list under
/// their finger.
class FeedLoaded extends FeedState {
  final List<PostEntity> posts;
  final String? nextCursor;
  final bool isLoadingMore;
  final List<UserBadgeEntity> pendingBadgeCelebrations;

  /// [posts] came from the device, not from this session's network.
  final bool isCached;

  /// The launch's fresh page is still on its way.
  final bool isRefreshing;

  /// A fresh first page held back until the user taps "New posts".
  final FeedPageEntity? newPage;

  /// One-shot: set when the launch refresh failed and the cached posts stay
  /// up, so the page can say so once. Dropped by [copyWith].
  final FeedErrorCode? refreshError;

  const FeedLoaded({
    required this.posts,
    required this.nextCursor,
    this.isLoadingMore = false,
    this.pendingBadgeCelebrations = const [],
    this.isCached = false,
    this.isRefreshing = false,
    this.newPage,
    this.refreshError,
  });

  bool get hasMore => nextCursor != null;

  FeedLoaded copyWith({
    List<PostEntity>? posts,
    String? nextCursor,
    bool? isLoadingMore,
  }) {
    return FeedLoaded(
      posts: posts ?? this.posts,
      nextCursor: nextCursor ?? this.nextCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      // One-shot: only the initial load carries these — never propagate them
      // through an in-place update.
      pendingBadgeCelebrations: const [],
      isCached: isCached,
      isRefreshing: isRefreshing,
      newPage: newPage,
    );
  }

  @override
  List<Object?> get props => [
    posts,
    nextCursor,
    isLoadingMore,
    pendingBadgeCelebrations,
    isCached,
    isRefreshing,
    newPage,
    refreshError,
  ];
}

class FeedError extends FeedState {
  final FeedErrorCode code;
  const FeedError(this.code);

  @override
  List<Object?> get props => [code];
}
