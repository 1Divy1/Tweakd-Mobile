import 'package:equatable/equatable.dart';

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
class FeedLoaded extends FeedState {
  final List<PostEntity> posts;
  final String? nextCursor;
  final bool isLoadingMore;

  const FeedLoaded({
    required this.posts,
    required this.nextCursor,
    this.isLoadingMore = false,
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
    );
  }

  @override
  List<Object?> get props => [posts, nextCursor, isLoadingMore];
}

class FeedError extends FeedState {
  final FeedErrorCode code;
  const FeedError(this.code);

  @override
  List<Object?> get props => [code];
}
