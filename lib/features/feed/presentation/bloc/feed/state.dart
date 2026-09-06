import 'package:equatable/equatable.dart';

import '../../../../badges/domain/entities/user_badge.dart';
import '../../../../posts/domain/entities/post.dart';
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
/// initial [LoadFeed] and is deliberately dropped by [copyWith] and never
/// carried by refresh or paging, so the celebration overlay consumes it once
/// per launch.
class FeedLoaded extends FeedState {
  final List<PostEntity> posts;
  final String? nextCursor;
  final bool isLoadingMore;
  final List<UserBadgeEntity> pendingBadgeCelebrations;

  const FeedLoaded({
    required this.posts,
    required this.nextCursor,
    this.isLoadingMore = false,
    this.pendingBadgeCelebrations = const [],
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
    );
  }

  @override
  List<Object?> get props => [
    posts,
    nextCursor,
    isLoadingMore,
    pendingBadgeCelebrations,
  ];
}

class FeedError extends FeedState {
  final FeedErrorCode code;
  const FeedError(this.code);

  @override
  List<Object?> get props => [code];
}
