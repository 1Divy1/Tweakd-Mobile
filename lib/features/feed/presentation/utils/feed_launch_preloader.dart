import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/startup_trace.dart';
import '../../domain/entities/feed_page.dart';
import '../../domain/usecases/get_cached_feed.dart';
import '../../domain/usecases/get_global_feed.dart';

/// What the first feed of a session opens with: the page saved last time, if
/// any, and the network request for a fresh one — already in flight.
class FeedLaunch {
  final FeedPageEntity? cached;
  final Future<Either<Failure, FeedPageEntity>> fresh;

  const FeedLaunch({required this.cached, required this.fresh});
}

/// Starts the feed's first load before there is a feed to show it.
///
/// `main()` calls [start] as soon as it knows the launch is going straight to
/// the feed, so the request goes out while the rest of the app is still being
/// set up rather than once `FeedPage` has mounted. The first `FeedBloc` then
/// picks up that same load with [take] instead of starting its own.
///
/// A launch that goes through the splash never calls [start]; its first
/// [take] starts the load there and then, so every session's first feed opens
/// the same way — cached page first, fresh page on top.
@lazySingleton
class FeedLaunchPreloader {
  final GetGlobalFeedUseCase getGlobalFeed;
  final GetCachedFeedUseCase getCachedFeed;

  FeedLaunchPreloader({
    required this.getGlobalFeed,
    required this.getCachedFeed,
  });

  Future<FeedLaunch>? _launch;
  bool _taken = false;

  /// Sends the request and reads the cache. Completes once the cache has been
  /// read — which is what the first frame needs — while the request carries
  /// on. Calling it again is a no-op.
  Future<void> start() => _launch ??= _load();

  /// Hands the launch load to the first feed that asks. Every later call gets
  /// null — a retry or a second feed page loads the ordinary way.
  Future<FeedLaunch>? take() {
    if (_taken) return null;
    _taken = true;
    return _launch ??= _load();
  }

  /// Forgets the launch load, so the next account to sign in opens its first
  /// feed the same way. Called on sign-out.
  void reset() {
    _launch = null;
    _taken = false;
  }

  Future<FeedLaunch> _load() async {
    // The request first: it is the slow part, so it goes on the wire before
    // the disk read rather than after it.
    StartupTrace.markOnce('feed request sent');
    final fresh = getGlobalFeed(const GetGlobalFeedParams()).then((result) {
      StartupTrace.markOnce('fresh feed arrived');
      return result;
    });
    final cached = (await getCachedFeed(
      NoParams(),
    )).fold((_) => null, (p) => p);
    StartupTrace.markOnce(
      cached == null ? 'feed cache miss' : 'feed cache read',
    );
    return FeedLaunch(cached: cached, fresh: fresh);
  }
}
