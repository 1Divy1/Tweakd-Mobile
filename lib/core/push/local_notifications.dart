import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

import 'push_message.dart';

/// Android notification channel every push lands on. Registered up-front so it
/// exists before the first notification arrives — Android creates a channel
/// lazily otherwise, and one created implicitly by FCM gets default (silent-
/// ish) importance that the user then has to fix by hand.
///
/// Kept in step with `default_notification_channel_id` in AndroidManifest.xml
/// and with `android.notification.channel_id` in the backend's FCM payload.
const _channelId = 'tweakd_default';
const _channelName = 'General';
/// Bare drawable resource name — the plugin resolves it with
/// `Resources.getIdentifier(name, "drawable", pkg)`, so an `@drawable/` prefix
/// would fail to resolve and `initialize` would throw.
///
/// Kept in step with `default_notification_icon` in AndroidManifest.xml, which
/// covers the notifications the OS draws itself while the app is backgrounded.
const _notificationIcon = 'ic_notification';

const _channelDescription =
    'Likes, comments, tags, forum replies and direct messages.';

/// Displays notifications the OS would otherwise swallow.
///
/// Only the **foreground** path needs this: Android never renders an incoming
/// FCM `notification` block while the app is in the foreground, so without a
/// locally-composed notification the user sees nothing until they open the
/// app. Background and terminated messages are drawn by the OS from the
/// `notification` block directly and never reach this class.
///
/// iOS needs none of it — `setForegroundNotificationPresentationOptions`
/// makes the system present its own banner in the foreground — so display is
/// Android-only here, while initialization runs on both so taps route the same
/// way on each platform.
@lazySingleton
class LocalNotifications {
  final _plugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Monotonic fallback id for messages with no `notification_id` to key on.
  int _fallbackId = 0;

  /// Sets up the plugin and creates the Android channel. [onTap] receives the
  /// payload of a notification the user tapped.
  ///
  /// Permission prompting is deliberately disabled here (`request*Permission:
  /// false`): `PushNotificationService` asks via `FirebaseMessaging`, which is
  /// also what registers the app with APNs. Letting this plugin ask as well
  /// would risk a second system prompt on the same screen.
  Future<void> init({required ValueChanged<PushMessage> onTap}) async {
    if (_initialized) return;
    _initialized = true;

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(_notificationIcon),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestSoundPermission: false,
          requestBadgePermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        final message = _decode(response.payload);
        if (message != null) onTap(message);
      },
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.high,
        ));
  }

  /// Draws [message] as a heads-up notification on Android. No-op elsewhere,
  /// and no-op when the message carries no title — a data-only push has
  /// nothing to render and is handled silently by the badge refresh instead.
  Future<void> show(PushMessage message) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    final title = message.title;
    if (title == null || title.isEmpty) return;

    await _plugin.show(
      id: _idFor(message),
      title: title,
      body: message.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: _notificationIcon,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  /// Derives a stable notification id from `notification_id` so a re-delivered
  /// push replaces its predecessor rather than stacking a duplicate. Messages
  /// without one fall back to a counter, which stacks — correct, since two
  /// such messages are genuinely unrelated.
  int _idFor(PushMessage message) {
    final id = message.notificationId;
    if (id == null || id.isEmpty) return _fallbackId++;
    // Masked to a non-negative 31-bit int: Android notification ids are Java
    // ints and a negative value from hashCode is legal but awkward to trace.
    return id.hashCode & 0x7fffffff;
  }

  /// Rebuilds a [PushMessage] from a tapped notification's payload. Returns
  /// null for anything that isn't the JSON object we wrote in [show] — the
  /// payload is round-tripped through the OS, so it is parsed defensively.
  PushMessage? _decode(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) return null;
      return PushMessage(data: coercePushData(decoded));
    } catch (e) {
      debugPrint('🔔 local notification payload decode failed: $e');
      return null;
    }
  }
}
