/// The session-facing half of push notifications: binding this installation's
/// FCM token to the signed-in user, and releasing it again on sign-out.
///
/// Declared in `core` so the authentication feature can retire the
/// registration during sign-out without importing the notifications feature.
/// The implementation (`PushTokenSync`) lives there, because it is our REST
/// contract — not FCM — that makes it a notifications concern.
abstract class PushRegistration {
  /// Registers the current token against the signed-in user. Idempotent, and a
  /// no-op once it has succeeded in this app run.
  Future<void> start();

  /// Retires this device's registration.
  ///
  /// **Must be awaited before the session is torn down** — it is authorized
  /// with the session it is retiring. Never throws.
  Future<void> unregister();
}
