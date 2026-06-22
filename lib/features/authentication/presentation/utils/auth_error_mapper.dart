import 'package:car_social_media_app/l10n/app_localizations.dart';

import '../../../../core/error/base_failures.dart';
import '../../domain/failures/auth_failures.dart';

/// User-facing error situations the auth flow can surface. The bloc emits these
/// codes (never strings); the UI maps them to localized copy via
/// [authErrorMessage].
enum AuthErrorCode { sessionExpired, generic }

class AuthErrorMapper {
  static AuthErrorCode getCode(Failure failure) {
    if (failure is UnauthenticatedFailure) return AuthErrorCode.sessionExpired;
    return AuthErrorCode.generic;
  }
}

/// Turns an [AuthErrorCode] into localized copy. Lives in the presentation
/// layer because it needs an [AppLocalizations] from a widget.
String authErrorMessage(AppLocalizations l10n, AuthErrorCode code) =>
    switch (code) {
      AuthErrorCode.sessionExpired => l10n.authErrorSessionExpired,
      AuthErrorCode.generic => l10n.authErrorGeneric,
    };
