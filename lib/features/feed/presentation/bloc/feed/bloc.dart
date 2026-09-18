import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/base_failures.dart' show Failure;
import '../../../../../core/utils/startup_trace.dart';
import '../../../../badges/domain/entities/user_badge.dart';
import '../../../../posts/domain/entities/post.dart';
import '../../../../posts/domain/usecases/add_comment.dart';
import '../../../../posts/domain/usecases/post_like.dart';
import '../../../../posts/domain/usecases/post_repost.dart';
import '../../../../posts/domain/usecases/post_save.dart';
import '../../../domain/entities/feed_page.dart';
import '../../../domain/usecases/get_global_feed.dart';
import '../../utils/feed_error_mapper.dart';
import '../../utils/feed_launch_preloader.dart';
import 'event.dart';
import 'state.dart';
import 'package:tweakd/core/analytics/analytics_events.dart';
import 'package:tweakd/core/analytics/analytics_service.dart';

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
  final FeedLaunchPreloader launchPreloader;

  /// Whether the user has scrolled the cached launch page. Decides whether the
  /// fresh page swaps in by itself or waits behind the "New posts" pill.
  bool _scrolledCache = false;

  /// Posts liked, saved, reposted or commented on while still cached. The
  /// fresh page was requested before those actions, so for these posts the
  /// on-screen version is newer than the server's and survives the swap.
  final _touchedWhileCached = <String>{};

  /// Posts hidden (reported) while still cached, kept out of the fresh page.
  final _hiddenWhileCached = <String>{};
  final AnalyticsService analytics;

  FeedBloc({
    required this.getGlobalFeed,
    required this.likePost,
    required this.unlikePost,
    required this.savePost,
    required this.unsavePost,
    required this.repostPost,
    required this.unrepostPost,
    required this.addComment,
    required this.launchPreloader,
    this.analytics = const NoopAnalyticsService(),
  }) : super(const FeedInitial()) {
    on<LoadFeed>(_onLoad);
    on<FeedCacheScrolled>(_onCacheScrolled);
    on<ShowNewFeedPosts>(_onShowNewPosts);
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
    if (current.isCached) _hiddenWhileCached.add(event.postId);
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

    if (current.isCached) _touchedWhileCached.add(event.postId);

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
    }, (_) {
      analytics.track(AnalyticsEvents.postCommented, {
        'is_reply': false,
        'source': 'feed',
      });
    });
  }

  Future<void> _onLoad(LoadFeed event, Emitter<FeedState> emit) async {
    final launch = launchPreloader.take();
    if (launch == null) {
      emit(const FeedLoading());
      final result = await getGlobalFeed(const GetGlobalFeedParams());
      _emitFirstPage(emit, result);
      return;
    }

    final FeedLaunch(:cached, :fresh) = await launch;
    if (cached != null && cached.items.isNotEmpty) {
      emit(
        FeedLoaded(
          posts: cached.items,
          nextCursor: cached.nextCursor,
          isCached: true,
          isRefreshing: true,
        ),
      );
    } else {
      emit(const FeedLoading());
    }

    final result = await fresh;
    final current = state;

    // Nothing cached on screen: the skeleton was up, so this is a plain first
    // load. Also the path when a pull-to-refresh already replaced the cache —
    // that data is newer, so only the one-shot celebrations are taken from here.
    if (current is! FeedLoaded || !current.isCached) {
      if (current is FeedLoaded) {
        result.fold((_) {}, (page) {
          if (page.pendingBadgeCelebrations.isEmpty) return;
          emit(_withCelebrations(current, page.pendingBadgeCelebrations));
        });
      } else {
        _emitFirstPage(emit, result);
      }
      return;
    }

    result.fold(
      // The cached posts stay; the page says the refresh failed.
      (failure) => emit(
        FeedLoaded(
          posts: current.posts,
          nextCursor: current.nextCursor,
          isLoadingMore: current.isLoadingMore,
          isCached: true,
          refreshError: FeedErrorMapper.getCode(failure),
        ),
      ),
      (page) {
        if (!_scrolledCache) {
          StartupTrace.markOnce('fresh feed swapped in');
          emit(
            FeedLoaded(
              posts: _mergeFresh(current.posts, page.items),
              nextCursor: page.nextCursor,
              pendingBadgeCelebrations: page.pendingBadgeCelebrations,
            ),
          );
          _clearCacheTracking();
          return;
        }
        // The user is reading the cached posts — don't move them. Celebrations
        // don't wait for the pill; they play over whatever is on screen.
        emit(
          FeedLoaded(
            posts: current.posts,
            nextCursor: current.nextCursor,
            isLoadingMore: current.isLoadingMore,
            isCached: true,
            newPage: page,
            pendingBadgeCelebrations: page.pendingBadgeCelebrations,
          ),
        );
      },
    );
  }

  void _onCacheScrolled(FeedCacheScrolled event, Emitter<FeedState> emit) {
    final current = state;
    if (current is FeedLoaded && current.isCached) _scrolledCache = true;
  }

  void _onShowNewPosts(ShowNewFeedPosts event, Emitter<FeedState> emit) {
    final current = state;
    if (current is! FeedLoaded) return;
    final page = current.newPage;
    if (page == null) return;
    emit(
      FeedLoaded(
        posts: _mergeFresh(current.posts, page.items),
        nextCursor: page.nextCursor,
      ),
    );
    _clearCacheTracking();
  }

  /// [fresh], minus posts hidden while cached, with the on-screen version kept
  /// for posts the user acted on while cached.
  List<PostEntity> _mergeFresh(
    List<PostEntity> onScreen,
    List<PostEntity> fresh,
  ) {
    final byId = {for (final p in onScreen) p.id: p};
    return [
      for (final p in fresh)
        if (!_hiddenWhileCached.contains(p.id))
          _touchedWhileCached.contains(p.id) ? (byId[p.id] ?? p) : p,
    ];
  }

  void _clearCacheTracking() {
    _touchedWhileCached.clear();
    _hiddenWhileCached.clear();
  }

  FeedLoaded _withCelebrations(
    FeedLoaded current,
    List<UserBadgeEntity> celebrations,
  ) => FeedLoaded(
    posts: current.posts,
    nextCursor: current.nextCursor,
    isLoadingMore: current.isLoadingMore,
    isCached: current.isCached,
    isRefreshing: current.isRefreshing,
    newPage: current.newPage,
    pendingBadgeCelebrations: celebrations,
  );

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
        (page) {
          emit(FeedLoaded(posts: page.items, nextCursor: page.nextCursor));
          _clearCacheTracking();
        },
      );
    } finally {
      // Always release the indicator, even when the data is identical and the
      // emit above is a no-op (Bloc dedups equal states).
      if (!(event.completer?.isCompleted ?? true)) event.completer!.complete();
    }
  }

  Future<void> _onLoadMore(LoadMoreFeed event, Emitter<FeedState> emit) async {
    final current = state;
    // While the launch refresh is out, or a fresh page is waiting behind the
    // pill, the cached cursor is about to be replaced — paging from it would
    // stitch two different rankings together.
    if (current is! FeedLoaded ||
        current.isLoadingMore ||
        !current.hasMore ||
        current.isRefreshing ||
        current.newPage != null) {
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
          isCached: current.isCached,
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
      track: (on) => analytics.track(
        on ? AnalyticsEvents.postLiked : AnalyticsEvents.postUnliked,
        {'source': 'feed'},
      ),
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
      track: (on) {
        if (on) analytics.track(AnalyticsEvents.postSaved, {'source': 'feed'});
      },
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
      track: (on) => analytics.track(
        on ? AnalyticsEvents.postReposted : AnalyticsEvents.postUnreposted,
        {'source': 'feed'},
      ),
    );
  }

  /// Shared optimistic toggle for like/save/repost: flips the flag + adjusts the
  /// matching counter immediately, then reverts that one post on failure.
  /// [track] records the change once the backend has accepted it.
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
    required void Function(bool on) track,
  }) async {
    final current = state;
    if (current is! FeedLoaded) return;

    final index = current.posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = current.posts[index];
    final on = !isOn(post);
    if (current.isCached) _touchedWhileCached.add(postId);

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
    }, (_) => track(on));
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
