import 'package:equatable/equatable.dart';

/// The platform a device registration belongs to. The wire values are what
/// the backend keys its FCM sends on (APNs vs FCM-Android differ in how a
/// payload has to be shaped), so they are fixed, not derived from an enum name.
enum DevicePlatform {
  ios('ios'),
  android('android');

  const DevicePlatform(this.wire);

  final String wire;
}

/// One installation registered to receive push notifications.
///
/// The registration is bound to the signed-in user **by the backend, from the
/// JWT** — the app never sends a user id. That is what makes re-registering an
/// existing token on a second account safe: the backend reassigns it rather
/// than fanning one device's pushes out to both users.
class PushDeviceEntity extends Equatable {
  /// The FCM registration token. Rotates on its own; see
  /// `PushNotificationService.tokenRefresh`.
  final String token;

  final DevicePlatform platform;

  /// `version+build`, so a delivery bug can be traced to a release without
  /// asking the user.
  final String appVersion;

  /// The user's app language (`en`/`ro`), letting the backend localize the
  /// notification title/body it composes. Null when it hasn't been chosen yet,
  /// in which case the backend falls back to the profile's locale.
  final String? locale;

  const PushDeviceEntity({
    required this.token,
    required this.platform,
    required this.appVersion,
    this.locale,
  });

  @override
  List<Object?> get props => [token, platform, appVersion, locale];
}
