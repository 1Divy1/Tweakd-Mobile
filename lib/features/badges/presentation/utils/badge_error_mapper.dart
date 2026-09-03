import 'package:tweakd/core/error/base_failures.dart';
import 'package:tweakd/l10n/app_localizations.dart';

/// User-facing error situations the badge strip can surface. The bloc emits
/// these codes (never strings); the UI maps them to localized copy via
/// [badgeErrorMessage].
enum BadgeErrorCode { network, generic }

class BadgeErrorMapper {
  static BadgeErrorCode getCode(Failure failure) {
    if (failure is NetworkFailure) return BadgeErrorCode.network;
    return BadgeErrorCode.generic;
  }
}

/// Turns a [BadgeErrorCode] into localized copy. Lives in the presentation
/// layer because it needs an [AppLocalizations] from a widget.
String badgeErrorMessage(AppLocalizations l10n, BadgeErrorCode code) =>
    switch (code) {
      BadgeErrorCode.network => l10n.profileErrorNetwork,
      BadgeErrorCode.generic => l10n.profileBadgesLoadError,
    };
