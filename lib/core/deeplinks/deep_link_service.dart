import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'share_link_route.dart';

/// Turns an incoming Universal Link / App Link into navigation.
///
/// **Why this listens to `app_links` instead of letting Flutter route deep
/// links itself.** Setting `FlutterDeepLinkingEnabled` /
/// `flutter_deeplinking_enabled` hands *every* incoming URL to go_router,
/// including the `tweakd://signup-callback` and `tweakd://login-callback`
/// URLs that Supabase's PKCE and Android Sign-in-with-Apple flows depend on.
/// Those have no route, and breaking sign-up to gain a share link is a bad
/// trade. Reading the same stream Supabase reads costs one subscription and
/// lets this class ignore everything that is not `/c/{code}` — see
/// [shareRouteFor]. `AppLinks()` is a Dart-side singleton over one broadcast
/// stream, so subscribing here does not displace Supabase's listener.
///
/// Holds no reference to the router (`app_router.dart` imports the pages,
/// which reach services through DI, so importing it back would close a cycle).
/// `main.dart` owns both and wires them together with [attach], exactly as it
/// does for push notifications.
@lazySingleton
class DeepLinkService {
  final AppLinks _appLinks;

  DeepLinkService(this._appLinks);

  void Function(String route)? _navigate;

  /// A destination waiting for the app to be ready for it — a cold start still
  /// resolving its session, or a signed-out user who has to get through
  /// sign-up first.
  String? _pending;

  /// Whether the app has landed on a real screen yet.
  ///
  /// Until it has, *nothing* is navigated to directly: the splash finishes by
  /// calling `context.go('/feed')`, which replaces the whole stack and would
  /// silently swallow a route pushed a moment earlier. [flushPending] is only
  /// called once the app is somewhere real, so it doubles as the signal that
  /// pushing is safe again.
  bool _ready = false;

  StreamSubscription<Uri>? _subscription;

  /// The last URI acted on, with the moment it happened. A cold start can see
  /// the launch URL twice — once from [AppLinks.getInitialLink] and once
  /// replayed onto the stream — and the two arrive in either order depending on
  /// who subscribed first. Ignoring an identical URI inside [_replayWindow]
  /// collapses that pair without blocking a genuine re-open later.
  String? _lastUri;
  DateTime? _lastUriAt;
  static const Duration _replayWindow = Duration(seconds: 3);

  /// Supplies the navigation callback. Called once from `main.dart`.
  void attach(void Function(String route) navigate) {
    _navigate = navigate;
  }

  /// Begins listening, and picks up the URL that launched the app, if any.
  Future<void> start() async {
    _subscription ??= _appLinks.uriLinkStream.listen(
      _handle,
      onError: (Object e) => debugPrint('🔗 deep link stream error: $e'),
    );

    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) _handle(initial);
    } catch (e) {
      debugPrint('🔗 initial deep link failed: $e');
    }
  }

  /// Navigates to a parked destination, if there is one.
  ///
  /// Called once the app has landed on its first authenticated screen — from
  /// the splash, and from the screens that finish sign-in and onboarding — so
  /// the car opens *on top of* a real stack and back goes somewhere sensible.
  void flushPending() {
    _ready = true;

    final route = _pending;
    final navigate = _navigate;
    if (route == null || navigate == null || !_signedIn) return;
    _pending = null;
    _go(navigate, route);
  }

  /// Drops any parked destination. Called on sign-out, so a link opened by the
  /// previous user cannot navigate whoever signs in next. Sign-out also sends
  /// the app back to the auth screens, so it stops being ready to be navigated.
  void clearPending() {
    _pending = null;
    _ready = false;
  }

  @disposeMethod
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _handle(Uri uri) {
    if (_isReplay(uri)) return;

    final route = shareRouteFor(uri);
    // Not a share link: an auth callback, or something we don't own. Left
    // alone on purpose — Supabase is listening to the same stream.
    if (route == null) return;

    final navigate = _navigate;
    if (navigate == null || !_ready || !_signedIn) {
      _pending = route;
      return;
    }
    _go(navigate, route);
  }

  bool _isReplay(Uri uri) {
    final now = DateTime.now();
    final seen = _lastUri == uri.toString() &&
        _lastUriAt != null &&
        now.difference(_lastUriAt!) < _replayWindow;
    _lastUri = uri.toString();
    _lastUriAt = now;
    return seen;
  }

  void _go(void Function(String route) navigate, String route) {
    // The link can land mid-frame (a route rebuild, the splash's own `go`).
    // Deferring by a frame keeps go_router from navigating during a build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        navigate(route);
      } catch (e) {
        debugPrint('🔗 deep link navigation to $route failed: $e');
      }
    });
  }

  bool get _signedIn => Supabase.instance.client.auth.currentSession != null;
}
