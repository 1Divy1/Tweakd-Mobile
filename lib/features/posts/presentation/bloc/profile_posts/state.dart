import 'package:equatable/equatable.dart';

import '../../../domain/entities/post.dart';
import '../../utils/post_error_mapper.dart';

sealed class ProfilePostsState extends Equatable {
  const ProfilePostsState();

  @override
  List<Object?> get props => [];
}

class ProfilePostsInitial extends ProfilePostsState {
  const ProfilePostsInitial();
}

class ProfilePostsLoading extends ProfilePostsState {
  const ProfilePostsLoading();
}

/// The loaded grid. [nextCursor] is null on the last page; [isLoadingMore]
/// guards the "load more" footer against duplicate fetches.
class ProfilePostsLoaded extends ProfilePostsState {
  final List<PostEntity> posts;
  final String? nextCursor;
  final bool isLoadingMore;

  const ProfilePostsLoaded({
    required this.posts,
    required this.nextCursor,
    this.isLoadingMore = false,
  });

  bool get hasMore => nextCursor != null;

  ProfilePostsLoaded copyWith({
    List<PostEntity>? posts,
    String? nextCursor,
    bool? isLoadingMore,
  }) {
    return ProfilePostsLoaded(
      posts: posts ?? this.posts,
      nextCursor: nextCursor ?? this.nextCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [posts, nextCursor, isLoadingMore];
}

class ProfilePostsError extends ProfilePostsState {
  final PostErrorCode code;
  const ProfilePostsError(this.code);

  @override
  List<Object?> get props => [code];
}
