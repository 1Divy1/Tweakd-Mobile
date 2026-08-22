import 'package:tweakd/core/error/base_failures.dart';
import 'package:tweakd/l10n/app_localizations.dart';

/// User-facing error situations the notifications list can surface. The bloc
/// emits a code (never a string); the UI maps it to localized copy via
/// [notificationsErrorMessage].
enum NotificationsErrorCode { network, generic }

class NotificationsErrorMapper {
  static NotificationsErrorCode getCode(Failure failure) {
    if (failure is NetworkFailure) return NotificationsErrorCode.network;
    return NotificationsErrorCode.generic;
  }
}

String notificationsErrorMessage(
  AppLocalizations l10n,
  NotificationsErrorCode code,
) =>
    switch (code) {
      NotificationsErrorCode.network => l10n.notificationsErrorNetwork,
      NotificationsErrorCode.generic => l10n.notificationsErrorGeneric,
    };
