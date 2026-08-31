import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'local_notifications.dart';
import 'push_message.dart';
import 'push_notification_service.dart';

/// FCM implementation of [PushNotificationService].
///
/// **On permission**: this class never prompts. The one and only system prompt
/// is the onboarding notifications step, which asks through
/// `PushPermissionService` (permission_handler). Calling
/// `FirebaseMessaging.requestPermission()` here as well would risk a second
/// prompt on the same screen, and it buys nothing: the iOS plugin already
/// calls `registerForRemoteNotifications` during plugin registration (see
/// `FLTFirebaseMessagingPlugin.m`), so the APNs token is fetched at launch
/// regardless of who asked for permission — and APNs registration itself needs
/// no user consent, only *displaying* a notification does.
///
/// A token is therefore obtained and registered even while permission is
/// denied. That is deliberate: it means granting permission later starts
/// delivering immediately instead of waiting for the next cold start, and on
/// Android below API 33 there is no permission to grant in the first place.
@LazySingleton(as: PushNotificationService)
class FirebasePushNotificationService implements PushNotificationService {
  final LocalNotifications _local;

  FirebasePushNotificationService(this._local);

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  final _opened = StreamController<PushMessage>.broadcast();
  final _received = StreamController<PushMessage>.broadcast();

  bool _started = false;

  /// Guards [takeInitialMessage] so a cold-start tap navigates exactly once.
  bool _initialMessageTaken = false;

  @override
  Stream<PushMessage> get opened => _opened.stream;

  @override
  Stream<PushMessage> get received => _received.stream;

  @override
  Stream<String> get tokenRefresh => _messaging.onTokenRefresh;

  @override
  Future<void> start() async {
    if (_started) return;
    _started = true;

    try {
      await _local.init(onTap: _opened.add);

      // iOS renders nothing for a foreground message unless asked to. Android
      // ignores this and is handled by [LocalNotifications.show] instead.
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp
          .listen((message) => _opened.add(_toPushMessage(message)));
    } catch (e) {
      // Push is best-effort: a failure here must never take startup with it.
      debugPrint('🔔 push start failed: $e');
    }
  }

  /// A message that arrived with the app open. Android draws nothing for these
  /// on its own, so one is composed locally; iOS has already shown its banner
  /// by this point. Either way the message is republished so the unread badges
  /// can update live.
  void _onForegroundMessage(RemoteMessage message) {
    final push = _toPushMessage(message);
    _received.add(push);
    unawaited(_local.show(push));
  }

  @override
  Future<String?> currentToken() async {
    try {
      if (!await _apnsTokenReady()) return null;
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('🔔 getToken failed: $e');
      return null;
    }
  }

  @override
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
    } catch (e) {
      debugPrint('🔔 deleteToken failed: $e');
    }
  }

  @override
  Future<PushMessage?> takeInitialMessage() async {
    if (_initialMessageTaken) return null;
    _initialMessageTaken = true;
    try {
      final message = await _messaging.getInitialMessage();
      return message == null ? null : _toPushMessage(message);
    } catch (e) {
      debugPrint('🔔 getInitialMessage failed: $e');
      return null;
    }
  }

  /// Since iOS SDK 10.4 `getToken()` fails unless the APNs token has already
  /// been assigned, and assignment is asynchronous — on a cold start the first
  /// call routinely lands before APNs has answered. Polls briefly rather than
  /// giving up, and gives up rather than hanging: a device with no APNs
  /// connectivity would otherwise wait forever.
  ///
  /// Always true off iOS, where there is no APNs token to wait for.
  Future<bool> _apnsTokenReady() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return true;

    for (var attempt = 0; attempt < _apnsAttempts; attempt++) {
      final token = await _messaging.getAPNSToken();
      if (token != null) return true;
      await Future<void>.delayed(_apnsRetryDelay * (attempt + 1));
    }
    debugPrint('🔔 APNs token unavailable — skipping FCM token this run');
    return false;
  }

  /// 5 attempts with a linear backoff — ~4.5s worst case. This runs on the
  /// token-sync path, never on the startup path, so a slow answer delays only
  /// the device registration.
  static const _apnsAttempts = 5;
  static const _apnsRetryDelay = Duration(milliseconds: 300);

  PushMessage _toPushMessage(RemoteMessage message) => PushMessage(
        data: coercePushData(message.data),
        title: message.notification?.title,
        body: message.notification?.body,
      );
}
