import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

/// Where the OS-level push notification permission currently stands, distilled
/// from [permission_handler]'s richer [PermissionStatus] into the few cases the
/// UI actually branches on.
enum PushPermission {
  /// Not granted yet, but the system prompt can still be shown.
  canRequest,

  /// The user granted notifications (or it's provisional/limited on iOS).
  granted,

  /// Blocked for good — the only way back is the OS settings screen.
  blocked,
}

/// Thin wrapper around [permission_handler] so the rest of the app talks about
/// push permission in our own terms and never imports the package directly.
@lazySingleton
class PushPermissionService {
  /// Reads the current permission without prompting the user.
  Future<PushPermission> current() async {
    return _map(await Permission.notification.status);
  }

  /// Shows the OS prompt (or resolves straight to the current state if the
  /// system won't prompt again) and reports the resulting permission.
  Future<PushPermission> request() async {
    return _map(await Permission.notification.request());
  }

  /// Opens the system settings page so the user can flip a blocked permission
  /// back on. Returns whether the settings screen was opened.
  Future<bool> openSettings() => openAppSettings();

  PushPermission _map(PermissionStatus status) {
    if (status.isGranted || status.isProvisional || status.isLimited) {
      return PushPermission.granted;
    }
    if (status.isPermanentlyDenied || status.isRestricted) {
      return PushPermission.blocked;
    }
    return PushPermission.canRequest;
  }
}
