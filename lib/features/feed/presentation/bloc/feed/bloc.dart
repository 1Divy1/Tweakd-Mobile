import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/base_failures.dart' show Failure;
import '../../../../posts/domain/entities/post.dart';
import '../../../../posts/domain/usecases/add_comment.dart';
import '../../../../posts/domain/usecases/post_like.dart';
import '../../../../posts/domain/usecases/post_repost.dart';
import '../../../../posts/domain/usecases/post_save.dart';
import '../../../domain/entities/feed_page.dart';
import '../../../domain/usecases/get_global_feed.dart';
import '../../utils/feed_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Drives the global feed page: first load, pull-to-refresh, cursor paging and
/// optimistic like / save / repost toggles. A feed item is a post, so those
/// reuse the posts feature's use cases.
@injectable
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final GetGlobalFeedUseCase getGlobalFeed;
  final LikePostUseCase likePost;
  final UnlikePostUseCase unlikePost;
  final SavePostUseCase savePost;
  final UnsavePostUseCase unsavePost;
  final RepostPostUseCase repostPost;
  final UnrepostPostUseCase unrepostPost;
  final AddCommentUseCase addComment;

  FeedBloc({
    required this.getGlobalFeed,
    required this.likePost,
    required this.unlikePost,
    required this.savePost,
    required this.unsavePost,
    required this.repostPost,
    required this.unrepostPost,
    required this.addComment,
  }) : super(const FeedInitial()) {
    on<LoadFeed>(_onLoad);
    on<RefreshFeed>(_onRefresh);
    on<LoadMoreFeed>(_onLoadMore);
    on<ToggleLikeFeedPost>(_onToggleLike);
    on<ToggleSaveFeedPost>(_onToggleSave);
    on<ToggleRepostFeedPost>(_onToggleRepost);
    on<UpdateFeedPostCommentCount>(_onUpdateCommentCount);
    on<SubmitFeedComment>(_onSubmitComment);
    on<HideFeedPost>(_onHidePost);
  }

  void _onHidePost(HideFeedPost event, Emitter<FeedState> emit) {
    final current = state;
    if (current is! FeedLoaded) return;
    emit(
      current.copyWith(
        posts: current.posts.where((p) => p.id != event.postId).toList(),
      ),
    );
  }

  void _onUpdateCommentCount(
    UpdateFeedPostCommentCount event,
    Emitter<FeedState> emit,
  ) {
    final current = state;
    if (current is! FeedLoaded) return;
    final index = current.posts.indexWhere((p) => p.id == event.postId);
    if (index == -1) return;
    emit(
      current.copyWith(
        posts: _replaceAt(
          current.posts,
          index,
          current.posts[index].copyWith(commentsCount: event.count),
        ),
      ),
    );
  }

  Future<void> _onSubmitComment(
    SubmitFeedComment event,
    Emitter<FeedState> emit,
  ) async {
    final content = event.content.trim();
    if (content.isEmpty) return;

    final current = state;
    if (current is! FeedLoaded) return;
    final index = current.posts.indexWhere((p) => p.id == event.postId);
    if (index == -1) return;

    // Optimistically bump the counter; the new comment shows when the sheet
    // (re)loads from the backend.
    final post = current.posts[index];
    emit(
      current.copyWith(
        posts: _replaceAt(
          current.posts,
          index,
          post.copyWith(commentsCount: post.commentsCount + 1),
        ),
      ),
    );

    final result = await addComment(
      AddCommentParams(postId: event.postId, content: content),
    );
    result.fold((_) {
      // Revert the bump on failure, re-finding the post in the latest state.
      final latest = state;
      if (latest is! FeedLoaded) return;
      final i = latest.posts.indexWhere((p) => p.id == event.postId);
      if (i == -1) return;
      final p = latest.posts[i];
      emit(
        latest.copyWith(
          posts: _replaceAt(
            latest.posts,
            i,
            p.copyWith(commentsCount: (p.commentsCount - 1).clamp(0, 1 << 31)),
          ),
        ),
      );
    }, (_) {});
  }

  Future<void> _onLoad(LoadFeed event, Emitter<FeedState> emit) async {
    emit(const FeedLoading());
    final result = await getGlobalFeed(const GetGlobalFeedParams());
    _emitFirstPage(emit, result);
  }

  Future<void> _onRefresh(RefreshFeed event, Emitter<FeedState> emit) async {
    try {
      final result = await getGlobalFeed(const GetGlobalFeedParams());
      // A failed refresh shouldn't blow away what's already on screen.
      final current = state;
      result.fold(
        (failure) {
          if (current is! FeedLoaded) {
            emit(FeedError(FeedErrorMapper.getCode(failure)));
          }
        },
        (page) =>
            emit(FeedLoaded(posts: page.items, nextCursor: page.nextCursor)),
      );
    } finally {
      // Always release the indicator, even when the data is identical and the
      // emit above is a no-op (Bloc dedups equal states).
      if (!(event.completer?.isCompleted ?? true)) event.completer!.complete();
    }
  }

  Future<void> _onLoadMore(LoadMoreFeed event, Emitter<FeedState> emit) async {
    final current = state;
    if (current is! FeedLoaded || current.isLoadingMore || !current.hasMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));

    final result = await getGlobalFeed(
      GetGlobalFeedParams(cursor: current.nextCursor),
    );

    result.fold(
      // A failed "load more" shouldn't blow away what's already on screen.
      (_) => emit(current.copyWith(isLoadingMore: false)),
      (page) => emit(
        FeedLoaded(
          // The viral feed is eventually consistent, so a page may re-send a post
          // we already hold — drop duplicates so the list keys stay unique.
          posts: _dedup([...current.posts, ...page.items]),
          nextCursor: page.nextCursor,
        ),
      ),
    );
  }

  Future<void> _onToggleLike(
    ToggleLikeFeedPost event,
    Emitter<FeedState> emit,
  ) {
    return _toggle(
      emit,
      postId: event.postId,
      isOn: (p) => p.viewerHasLiked,
      flip: (p, on) => p.copyWith(
        viewerHasLiked: on,
        likesCount: (p.likesCount + (on ? 1 : -1)).clamp(0, 1 << 31),
      ),
      call: (id, on) => on ? likePost(id) : unlikePost(id),
    );
  }

  Future<void> _onToggleSave(
    ToggleSaveFeedPost event,
    Emitter<FeedState> emit,
  ) {
    return _toggle(
      emit,
      postId: event.postId,
      isOn: (p) => p.viewerHasSaved,
      flip: (p, on) => p.copyWith(
        viewerHasSaved: on,
        savedCount: (p.savedCount + (on ? 1 : -1)).clamp(0, 1 << 31),
      ),
      call: (id, on) => on ? savePost(id) : unsavePost(id),
    );
  }

  Future<void> _onToggleRepost(
    ToggleRepostFeedPost event,
    Emitter<FeedState> emit,
  ) {
    return _toggle(
      emit,
      postId: event.postId,
      isOn: (p) => p.viewerHasReposted,
      flip: (p, on) => p.copyWith(
        viewerHasReposted: on,
        sharesCount: (p.sharesCount + (on ? 1 : -1)).clamp(0, 1 << 31),
      ),
      call: (id, on) => on ? repostPost(id) : unrepostPost(id),
    );
  }

  /// Shared optimistic toggle for like/save/repost: flips the flag + adjusts the
  /// matching counter immediately, then reverts that one post on failure.
  Future<void> _toggle(
    Emitter<FeedState> emit, {
    required String postId,
    required bool Function(PostEntity) isOn,
    required PostEntity Function(PostEntity post, bool on) flip,
    required Future<Either<Failure, void>> Function(
      PostIdParams params,
      bool on,
    )
    call,
  }) async {
    final current = state;
    if (current is! FeedLoaded) return;

    final index = current.posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = current.posts[index];
    final on = !isOn(post);

    emit(
      current.copyWith(posts: _replaceAt(current.posts, index, flip(post, on))),
    );

    final result = await call(PostIdParams(postId: post.id), on);
    result.fold((_) {
      final latest = state;
      if (latest is! FeedLoaded) return;
      final i = latest.posts.indexWhere((p) => p.id == postId);
      if (i == -1) return;
      emit(latest.copyWith(posts: _replaceAt(latest.posts, i, post)));
    }, (_) {});
  }

  void _emitFirstPage(
    Emitter<FeedState> emit,
    Either<Failure, FeedPageEntity> result,
  ) {
    result.fold(
      (failure) => emit(FeedError(FeedErrorMapper.getCode(failure))),
      (page) => emit(
        FeedLoaded(
          posts: page.items,
          nextCursor: page.nextCursor,
          // Only the initial load surfaces these; the feed page hands them to the
          // celebration overlay and they are gone from the next state onward.
          pendingBadgeCelebrations: page.pendingBadgeCelebrations,
        ),
      ),
    );
  }

  List<PostEntity> _replaceAt(List<PostEntity> posts, int index, PostEntity p) {
    final next = [...posts];
    next[index] = p;
    return next;
  }

  List<PostEntity> _dedup(List<PostEntity> posts) {
    final seen = <String>{};
    return [
      for (final p in posts)
        if (seen.add(p.id)) p,
    ];
  }
}
