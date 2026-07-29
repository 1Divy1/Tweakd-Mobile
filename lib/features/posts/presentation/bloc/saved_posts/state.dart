import 'package:equatable/equatable.dart';

import '../../../domain/entities/post.dart';
import '../../utils/post_error_mapper.dart';

sealed class SavedPostsState extends Equatable {
  const SavedPostsState();

  @override
  List<Object?> get props => [];
}

class SavedPostsInitial extends SavedPostsState {
  const SavedPostsInitial();
}

class SavedPostsLoading extends SavedPostsState {
  const SavedPostsLoading();
}

/// The loaded grid. [nextCursor] is null on the last page; [isLoadingMore]
/// guards the "load more" footer against duplicate fetches.
class SavedPostsLoaded extends SavedPostsState {
  final List<PostEntity> posts;
  final String? nextCursor;
  final bool isLoadingMore;

  const SavedPostsLoaded({
    required this.posts,
    required this.nextCursor,
    this.isLoadingMore = false,
  });

  bool get hasMore => nextCursor != null;

  SavedPostsLoaded copyWith({
    List<PostEntity>? posts,
    String? nextCursor,
    bool? isLoadingMore,
  }) {
    return SavedPostsLoaded(
      posts: posts ?? this.posts,
      nextCursor: nextCursor ?? this.nextCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [posts, nextCursor, isLoadingMore];
}

class SavedPostsError extends SavedPostsState {
  final PostErrorCode code;
  const SavedPostsError(this.code);

  @override
  List<Object?> get props => [code];
}
