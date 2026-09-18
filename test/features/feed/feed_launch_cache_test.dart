// The launch opens on the cached first page and refreshes it in place: the
// fresh page swaps in by itself unless the user already started scrolling, in
// which case it waits behind the "New posts" pill.
import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/core/error/base_failures.dart';
import 'package:tweakd/features/badges/data/models/user_badge_model.dart';
import 'package:tweakd/features/feed/domain/entities/feed_page.dart';
import 'package:tweakd/features/feed/domain/repositories/feed_repository.dart';
import 'package:tweakd/features/feed/domain/usecases/get_cached_feed.dart';
import 'package:tweakd/features/feed/domain/usecases/get_global_feed.dart';
import 'package:tweakd/features/feed/presentation/bloc/feed/bloc.dart';
import 'package:tweakd/features/feed/presentation/bloc/feed/event.dart';
import 'package:tweakd/features/feed/presentation/bloc/feed/state.dart';
import 'package:tweakd/features/feed/presentation/utils/feed_error_mapper.dart';
import 'package:tweakd/features/feed/presentation/utils/feed_launch_preloader.dart';
import 'package:tweakd/features/posts/data/models/post_models.dart';
import 'package:tweakd/features/posts/domain/entities/post.dart';
import 'package:tweakd/features/posts/domain/repositories/posts_repository.dart';
import 'package:tweakd/features/posts/domain/usecases/add_comment.dart';
import 'package:tweakd/features/posts/domain/usecases/post_like.dart';
import 'package:tweakd/features/posts/domain/usecases/post_repost.dart';
import 'package:tweakd/features/posts/domain/usecases/post_save.dart';

PostEntity _post(String id, {int likes = 0}) => PostModel.fromJson({
  'id': id,
  'description': 'Post $id',
  'author': {'id': 'a1', 'username': 'author'},
  'images': <dynamic>[],
  'tagged_people': <dynamic>[],
  'tagged_cars': <dynamic>[],
  'likes_count': likes,
  'comments_count': 0,
  'shares_count': 0,
  'saved_count': 0,
  'created_at': '2026-09-14T10:00:00Z',
}).toEntity();

FeedPageEntity _page(List<String> ids, {String? cursor = 'next'}) =>
    FeedPageEntity(items: [for (final id in ids) _post(id)], nextCursor: cursor);

class _FakeFeedRepository implements FeedRepository {
  FeedPageEntity? cached;

  /// The launch's first-page request; completed by the test.
  final firstPage = Completer<Either<Failure, FeedPageEntity>>();
  int pagedRequests = 0;

  @override
  Future<Either<Failure, FeedPageEntity>> getGlobalFeed({
    String? cursor,
    int size = 20,
  }) {
    if (cursor == null) return firstPage.future;
    pagedRequests++;
    return Future.value(Right(_page(['paged'], cursor: null)));
  }

  @override
  Future<FeedPageEntity?> getCachedFirstPage() async => cached;

  @override
  Future<void> clearCache() async => cached = null;
}

class _FakePostsRepository implements PostsRepository {
  @override
  Future<Either<Failure, void>> likePost(String postId) async =>
      const Right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

FeedBloc _bloc(_FakeFeedRepository feed) {
  final posts = _FakePostsRepository();
  final getGlobalFeed = GetGlobalFeedUseCase(feed);
  return FeedBloc(
    getGlobalFeed: getGlobalFeed,
    likePost: LikePostUseCase(posts),
    unlikePost: UnlikePostUseCase(posts),
    savePost: SavePostUseCase(posts),
    unsavePost: UnsavePostUseCase(posts),
    repostPost: RepostPostUseCase(posts),
    unrepostPost: UnrepostPostUseCase(posts),
    addComment: AddCommentUseCase(posts),
    launchPreloader: FeedLaunchPreloader(
      getGlobalFeed: getGlobalFeed,
      getCachedFeed: GetCachedFeedUseCase(feed),
    ),
  );
}

FeedLoaded _loaded(FeedBloc bloc) => bloc.state as FeedLoaded;

List<String> _ids(FeedBloc bloc) => [for (final p in _loaded(bloc).posts) p.id];

void main() {
  late _FakeFeedRepository feed;
  late FeedBloc bloc;

  setUp(() {
    feed = _FakeFeedRepository()..cached = _page(['old1', 'old2']);
    bloc = _bloc(feed);
  });

  tearDown(() => bloc.close());

  test('opens on the cached page, marked as cached and refreshing', () async {
    bloc.add(const LoadFeed());
    await pumpEventQueue();

    expect(_ids(bloc), ['old1', 'old2']);
    expect(_loaded(bloc).isCached, isTrue);
    expect(_loaded(bloc).isRefreshing, isTrue);
  });

  test('not scrolled: the fresh page swaps in place', () async {
    bloc.add(const LoadFeed());
    await pumpEventQueue();

    feed.firstPage.complete(Right(_page(['new1', 'new2'])));
    await pumpEventQueue();

    expect(_ids(bloc), ['new1', 'new2']);
    expect(_loaded(bloc).isCached, isFalse);
    expect(_loaded(bloc).isRefreshing, isFalse);
    expect(_loaded(bloc).newPage, isNull);
  });

  test('scrolled: the fresh page waits behind the pill until tapped', () async {
    bloc.add(const LoadFeed());
    await pumpEventQueue();
    bloc.add(const FeedCacheScrolled());
    await pumpEventQueue();

    feed.firstPage.complete(Right(_page(['new1'])));
    await pumpEventQueue();

    expect(_ids(bloc), ['old1', 'old2'], reason: 'nothing moves mid-read');
    expect(_loaded(bloc).newPage, isNotNull);
    expect(_loaded(bloc).isRefreshing, isFalse);

    bloc.add(const ShowNewFeedPosts());
    await pumpEventQueue();

    expect(_ids(bloc), ['new1']);
    expect(_loaded(bloc).newPage, isNull);
    expect(_loaded(bloc).isCached, isFalse);
  });

  test('badge celebrations play on arrival, not when the pill is tapped',
      () async {
    bloc.add(const LoadFeed());
    await pumpEventQueue();
    bloc.add(const FeedCacheScrolled());
    await pumpEventQueue();

    final badge = UserBadgeModel.fromJson({
      'badge': {
        'id': 'pioneer',
        'title': 'Pioneer',
        'description': 'One of the first.',
        'unlocked_url': 'https://assets.tweakd.app/u.svg',
        'locked_url': 'https://assets.tweakd.app/l.svg',
        'available': true,
        'created_at': '2026-09-03T16:22:34Z',
      },
      'earned_at': '2026-09-03T17:00:00Z',
    }).toEntity();
    feed.firstPage.complete(
      Right(
        FeedPageEntity(
          items: [_post('new1')],
          nextCursor: null,
          pendingBadgeCelebrations: [badge],
        ),
      ),
    );
    await pumpEventQueue();
    expect(_loaded(bloc).pendingBadgeCelebrations, [badge]);

    bloc.add(const ShowNewFeedPosts());
    await pumpEventQueue();
    expect(_loaded(bloc).pendingBadgeCelebrations, isEmpty);
  });

  test('a failed refresh keeps the cached posts and reports once', () async {
    bloc.add(const LoadFeed());
    await pumpEventQueue();

    feed.firstPage.complete(const Left(NetworkFailure('offline')));
    await pumpEventQueue();

    expect(_ids(bloc), ['old1', 'old2']);
    expect(_loaded(bloc).isRefreshing, isFalse);
    expect(_loaded(bloc).refreshError, FeedErrorCode.network);
  });

  test('no cache: skeleton, then the fresh page', () async {
    feed.cached = null;
    bloc.add(const LoadFeed());
    await pumpEventQueue();
    expect(bloc.state, isA<FeedLoading>());

    feed.firstPage.complete(Right(_page(['new1'])));
    await pumpEventQueue();
    expect(_ids(bloc), ['new1']);
  });

  test('a like on a cached post survives the swap', () async {
    feed.cached = FeedPageEntity(
      items: [_post('p1', likes: 3)],
      nextCursor: null,
    );
    bloc.add(const LoadFeed());
    await pumpEventQueue();

    bloc.add(const ToggleLikeFeedPost('p1'));
    await pumpEventQueue();

    // The server answered from before the like landed.
    feed.firstPage.complete(
      Right(FeedPageEntity(items: [_post('p1', likes: 3)], nextCursor: null)),
    );
    await pumpEventQueue();

    final post = _loaded(bloc).posts.single;
    expect(post.viewerHasLiked, isTrue);
    expect(post.likesCount, 4);
  });

  test('no paging from the cached cursor while the refresh is out', () async {
    bloc.add(const LoadFeed());
    await pumpEventQueue();

    bloc.add(const LoadMoreFeed());
    await pumpEventQueue();

    expect(feed.pagedRequests, 0);
    expect(_ids(bloc), ['old1', 'old2']);
  });

  test('only the first load uses the launch path', () async {
    bloc.add(const LoadFeed());
    await pumpEventQueue();
    feed.firstPage.complete(Right(_page(['new1'])));
    await pumpEventQueue();

    // A retry: no cache flash, straight to loading.
    final states = <FeedState>[];
    final sub = bloc.stream.listen(states.add);
    bloc.add(const LoadFeed());
    await pumpEventQueue();
    await sub.cancel();

    expect(states.first, isA<FeedLoading>());
  });
}
