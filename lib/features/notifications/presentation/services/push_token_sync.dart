import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/push/push_notification_service.dart';
import '../../../../core/push/push_registration.dart';
import '../../../../core/storage/locale_local_storage.dart';
import '../../domain/entities/push_device.dart';
import '../../domain/usecases/register_device.dart';
import '../../domain/usecases/unregister_device.dart';

/// Keeps the backend's idea of this installation's FCM token in step with the
/// session.
///
/// Lives in the notifications feature rather than `core/push` because it is
/// the REST contract that makes it a *notifications* concern — `core` owns the
/// FCM plumbing and nothing about our endpoints. It consumes use cases the way
/// a bloc does, hence its place in the presentation layer, though it holds no
/// UI state of its own.
///
/// Every failure is swallowed and logged, exactly like
/// `NotificationsUnreadCubit.refresh`: push is an enhancement, and a device
/// that can't register must still be a working app.
@LazySingleton(as: PushRegistration)
class PushTokenSync implements PushRegistration {
  final PushNotificationService push;
  final RegisterDeviceUseCase registerDevice;
  final UnregisterDeviceUseCase unregisterDevice;
  final LocaleLocalStorage localeStorage;

  PushTokenSync({
    required this.push,
    required this.registerDevice,
    required this.unregisterDevice,
    required this.localeStorage,
  });

  /// The token last sent to the backend. Kept so sign-out can unregister the
  /// exact registration that was created, without depending on FCM still
  /// being able to hand the token back at that moment.
  String? _registeredToken;

  StreamSubscription<String>? _refreshSub;

  /// Serializes overlapping calls — `signedIn`, `initialSession` and
  /// `tokenRefreshed` can all fire within the same second on a cold start, and
  /// each would otherwise start its own registration.
  Future<void>? _inFlight;

  /// Registers the current token and starts watching for rotations.
  ///
  /// Safe to call on every auth event: the backend upsert is idempotent. It
  /// deliberately re-registers on each app start rather than caching "already
  /// sent" locally — one small request buys self-healing when a registration
  /// is dropped server-side, when the app updates, or when a *different*
  /// account signs in on this device and the token has to be reassigned.
  @override
  Future<void> start() {
    final existing = _inFlight;
    if (existing != null) return existing;
    final run = _start().whenComplete(() => _inFlight = null);
    _inFlight = run;
    return run;
  }

  Future<void> _start() async {
    // Already registered in this app run: the backend has the current token,
    // and any rotation from here on arrives via [tokenRefresh].
    if (_registeredToken != null) return;

    _refreshSub ??= push.tokenRefresh.listen(
      _register,
      onError: (Object e) => debugPrint('🔔 token refresh stream error: $e'),
    );

    final token = await push.currentToken();
    if (token == null) return;
    await _register(token);
  }

  Future<void> _register(String token) async {
    try {
      final info = await PackageInfo.fromPlatform();
      final device = PushDeviceEntity(
        token: token,
        platform: defaultTargetPlatform == TargetPlatform.iOS
            ? DevicePlatform.ios
            : DevicePlatform.android,
        appVersion: '${info.version}+${info.buildNumber}',
        locale: await localeStorage.getLocale(),
      );

      final result = await registerDevice(device);
      result.fold(
        (failure) => debugPrint('🔔 device registration failed: ${failure.message}'),
        (_) => _registeredToken = token,
      );
    } catch (e) {
      debugPrint('🔔 device registration error: $e');
    }
  }

  /// Retires this device's registration on sign-out.
  ///
  /// **Must run before `supabaseClient.auth.signOut()`** — the request is
  /// authorized with the very session being torn down, and once that is gone
  /// the DELETE can only 401, leaving the token bound to the user who just
  /// left. The FCM token is dropped locally either way, so a failed DELETE
  /// still stops delivery to this install; the stale row is then cleaned up by
  /// the backend when the next account on this device re-registers the token.
  @override
  Future<void> unregister() async {
    await _refreshSub?.cancel();
    _refreshSub = null;

    final token = _registeredToken ?? await push.currentToken();
    _registeredToken = null;

    if (token != null) {
      final result = await unregisterDevice(token);
      result.fold(
        (failure) => debugPrint('🔔 device unregistration failed: ${failure.message}'),
        (_) {},
      );
    }

    // Invalidate the token itself so this install stops receiving pushes even
    // if the DELETE above never reached the backend. FCM mints a fresh one on
    // the next sign-in.
    await push.deleteToken();
  }
}
