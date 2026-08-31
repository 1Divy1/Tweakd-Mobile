import 'push_message.dart';

/// The app-wide push notification layer (FCM).
///
/// Split interface/implementation the same way `core/realtime/` is, so the
/// rest of the app never imports `firebase_messaging` directly and the whole
/// thing can be stubbed in tests.
///
/// Lifecycle: [start] once per app run (idempotent). Token registration with
/// the backend is *not* done here — that belongs to the notifications feature,
/// which owns the REST contract; this layer only surfaces the token.
abstract class PushNotificationService {
  /// Requests permission, wires the FCM listeners and prepares local-
  /// notification display. Safe to call repeatedly; only the first call does
  /// work. Never throws — push is best-effort and must not break startup.
  Future<void> start();

  /// Notifications the user tapped, from the background or from a local
  /// notification this app displayed itself. Cold-start taps are *not* on this
  /// stream — see [takeInitialMessage].
  Stream<PushMessage> get opened;

  /// Every message that arrived while the app was in the foreground. Used to
  /// keep the unread badges live; display is handled internally.
  Stream<PushMessage> get received;

  /// Fires whenever FCM rotates the registration token. The token must be
  /// re-sent to the backend each time, or the device silently stops receiving.
  Stream<String> get tokenRefresh;

  /// The current FCM registration token, or null when it can't be obtained
  /// (permission denied, no Play Services, APNs token not yet assigned).
  Future<String?> currentToken();

  /// Drops the FCM token so this install stops receiving pushes entirely.
  /// Called on sign-out, after the backend registration has been removed.
  Future<void> deleteToken();

  /// The notification that launched the app from a terminated state, if any.
  /// Consumed once — a second call returns null — so a hot restart or a late
  /// listener can't replay the same navigation.
  Future<PushMessage?> takeInitialMessage();
}
