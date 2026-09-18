import 'package:go_router/go_router.dart';

import 'analytics_service.dart';

/// Sends a screen view whenever the top-most route changes, including routes
/// opened with `push`.
///
/// Uses the route *pattern* (`/users/:username`, `/posts/:postId`) rather than
/// the location, so screen names never carry a username or an id, and every
/// profile counts as the same screen.
class AnalyticsScreenTracker {
  final GoRouter _router;
  final AnalyticsService _analytics;
  String? _last;

  AnalyticsScreenTracker._(this._router, this._analytics);

  /// Starts tracking [router]'s navigation. Lives as long as the app does.
  static void attach(GoRouter router, AnalyticsService analytics) {
    final tracker = AnalyticsScreenTracker._(router, analytics);
    router.routerDelegate.addListener(tracker._onRouteChanged);
  }

  void _onRouteChanged() {
    final String? pattern;
    try {
      pattern = _router.state.fullPath;
    } catch (_) {
      // No match yet (the router is still resolving its first location).
      return;
    }
    if (pattern == null || pattern.isEmpty || pattern == _last) return;
    _last = pattern;
    _analytics.screen(pattern);
  }
}
