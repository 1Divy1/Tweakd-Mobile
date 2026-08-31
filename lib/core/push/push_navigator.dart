import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/notifications/domain/entities/notification.dart';
import 'push_message.dart';

/// Turns a tapped notification into navigation.
///
/// Route selection (and the id validation that protects it) lives in
/// `notificationRouteFor`, shared with the in-app notifications list so a push
/// tap and a list tap can never drift apart.
///
/// Every destination is a plain path. Nothing is carried as go_router `extra`:
/// a route that can only be entered with state attached is a route a
/// notification cannot reliably open — which is precisely how DM taps ended up
/// dead-ending at the inbox. Screens reached this way resolve what they need
/// from their id.
///
/// Holds no reference to the router: `app_router.dart` imports the pages,
/// which reach this class through DI, so importing it back would close an
/// import cycle. `main.dart` — which already owns both — wires the two
/// together with [attach] instead.
@lazySingleton
class PushNavigator {
  void Function(String route)? _navigate;

  /// A cold-start destination waiting for the app to be ready for it.
  String? _pending;

  /// Supplies the navigation callback. Called once from `main.dart`.
  void attach(void Function(String route) navigate) {
    _navigate = navigate;
  }

  /// Handles a tap on [message].
  ///
  /// Navigates straight away when the user is signed in and the app is past
  /// the splash; otherwise the destination is parked until [flushPending].
  /// Being signed out is the interesting case: a tap must never jump the auth
  /// gate, and the notification is still worth honouring once the session
  /// resolves a moment later.
  void handleTap(PushMessage message) {
    final route = _routeFor(message);
    if (route == null) return;

    final navigate = _navigate;
    if (navigate == null || !_signedIn) {
      _pending = route;
      return;
    }
    _go(navigate, route);
  }

  /// Parks [message] for [flushPending] without navigating. Used for the
  /// message that launched the app from a terminated state, which arrives
  /// while the splash is still resolving the session.
  void deferTap(PushMessage message) {
    final route = _routeFor(message);
    if (route != null) _pending = route;
  }

  /// Navigates to a parked destination, if there is one. Called once the app
  /// has landed on its first authenticated screen (see `SplashPage`), so the
  /// destination is pushed *onto* the feed and back returns somewhere sane
  /// rather than to an empty stack.
  void flushPending() {
    final route = _pending;
    final navigate = _navigate;
    if (route == null || navigate == null || !_signedIn) return;
    _pending = null;
    _go(navigate, route);
  }

  /// Drops any parked destination. Called on sign-out so a notification tapped
  /// by the previous user can't navigate the next one into their content.
  void clearPending() => _pending = null;

  String? _routeFor(PushMessage message) => notificationRouteFor(
        NotificationType.fromWire(message.type),
        message.data,
      );

  void _go(void Function(String route) navigate, String route) {
    // The tap can land mid-frame (a route rebuild, the splash's own `go`).
    // Deferring by a frame keeps go_router from navigating during a build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        navigate(route);
      } catch (e) {
        debugPrint('🔔 push navigation to $route failed: $e');
      }
    });
  }

  bool get _signedIn => Supabase.instance.client.auth.currentSession != null;
}
