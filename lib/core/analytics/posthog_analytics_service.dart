import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import 'analytics_service.dart';

/// [AnalyticsService] on PostHog (EU cloud).
///
/// The native SDKs are kept from starting on their own (`AUTO_INIT` off in
/// Info.plist / AndroidManifest.xml); this class sets PostHog up from Dart,
/// **opted out**, and only opts in once the signed-in account's consent is
/// known to be granted.
///
/// Consent is also remembered on the device — just the id of the user who
/// agreed, in secure storage next to the session, so the logout sweep
/// (`FlutterSecureStorage().deleteAll()`) takes it too. That lets a fast
/// launch, which skips the profile lookup, resume tracking immediately; the
/// background check then confirms or withdraws it through [applyConsent].
@LazySingleton(as: AnalyticsService)
class PostHogAnalyticsService implements AnalyticsService {
  static const _projectToken = String.fromEnvironment('POSTHOG_PROJECT_TOKEN');

  /// Defaults to the EU host on purpose: a blank host makes the SDK fall back
  /// to PostHog's *US* cloud, and this data must stay in the EU.
  static const _host = String.fromEnvironment(
    'POSTHOG_HOST',
    defaultValue: 'https://eu.i.posthog.com',
  );
  static const _environment = String.fromEnvironment(
    'APP_ENVIRONMENT',
    defaultValue: 'dev',
  );
  static const _consentedUserKey = 'analytics_consented_user_id';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Posthog _posthog = Posthog();

  /// Completes once [start] has run; every SDK call waits for it, so a
  /// consent change that races the launch can't reach an unconfigured SDK.
  final Completer<void> _ready = Completer<void>();

  /// False when the build has no project token (no `--dart-define-from-file`):
  /// analytics then stays inert for the whole run.
  bool _configured = false;

  /// Whether events are being sent right now. Checked synchronously by
  /// [track] and [screen] so nothing is queued while opted out.
  bool _enabled = false;

  /// The user tracking is currently tied to, so a repeat [applyConsent] for
  /// the same user (every profile check calls it) is a no-op.
  String? _identifiedUserId;

  @override
  Future<void> start({String? currentUserId}) async {
    try {
      if (_projectToken.isEmpty) {
        debugPrint('Analytics off: no POSTHOG_PROJECT_TOKEN in this build.');
        return;
      }

      final consentedUserId = await _readConsentedUser();
      final resume = currentUserId != null && consentedUserId == currentUserId;

      final config = PostHogConfig(_projectToken)
        ..host = _host
        ..optOut = !resume
        ..captureApplicationLifecycleEvents = true
        ..personProfiles = PostHogPersonProfiles.identifiedOnly
        // Only what was agreed for v1: events + screen views.
        ..sessionReplay = false
        ..surveys = false
        ..preloadFeatureFlags = false
        ..sendFeatureFlagEvents = false
        // PostHog is not our push provider; device tokens stay with us.
        ..capturePushNotificationSubscriptions = false
        ..capturePushNotificationOpened = false
        ..debug = kDebugMode;

      await _posthog.setup(config);
      await _posthog.register('environment', _environment);
      _configured = true;

      if (resume) {
        await _posthog.enable();
        await _posthog.identify(userId: currentUserId);
        _identifiedUserId = currentUserId;
        _enabled = true;
      } else {
        await _posthog.disable();
      }
    } catch (e) {
      debugPrint('Analytics setup failed: ${e.runtimeType}');
      _configured = false;
    } finally {
      if (!_ready.isCompleted) _ready.complete();
    }
  }

  @override
  Future<void> applyConsent({
    required String userId,
    required bool granted,
  }) async {
    await _ready.future;
    if (!_configured) return;
    try {
      if (granted) {
        if (_enabled && _identifiedUserId == userId) return;
        await _posthog.enable();
        await _posthog.identify(userId: userId);
        _identifiedUserId = userId;
        _enabled = true;
        await _storage.write(key: _consentedUserKey, value: userId);
      } else {
        _enabled = false;
        _identifiedUserId = null;
        // Send what is queued first (e.g. the withdrawal itself) — reset
        // starts a fresh anonymous identity.
        await _posthog.flush();
        await _posthog.reset();
        await _posthog.disable();
        await _storage.delete(key: _consentedUserKey);
      }
    } catch (e) {
      debugPrint('Analytics consent update failed: ${e.runtimeType}');
    }
  }

  @override
  Future<void> clearUser() async {
    await _ready.future;
    if (!_configured) return;
    _enabled = false;
    _identifiedUserId = null;
    try {
      await _posthog.flush();
      await _posthog.reset();
      await _posthog.disable();
      await _storage.delete(key: _consentedUserKey);
    } catch (e) {
      debugPrint('Analytics reset failed: ${e.runtimeType}');
    }
  }

  @override
  void track(String event, [Map<String, Object>? properties]) {
    if (!_enabled) return;
    unawaited(
      _posthog
          .capture(eventName: event, properties: properties)
          .catchError((Object e) => debugPrint('Analytics capture failed: $e')),
    );
  }

  @override
  void screen(String name) {
    if (!_enabled) return;
    unawaited(
      _posthog
          .screen(screenName: name)
          .catchError((Object e) => debugPrint('Analytics screen failed: $e')),
    );
  }

  Future<String?> _readConsentedUser() async {
    try {
      return await _storage.read(key: _consentedUserKey);
    } catch (e) {
      debugPrint('Failed to read analytics consent: ${e.runtimeType}');
      return null;
    }
  }
}
