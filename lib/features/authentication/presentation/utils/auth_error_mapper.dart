import 'package:tweakd/l10n/app_localizations.dart';

import '../../../../core/error/base_failures.dart';
import '../../domain/failures/auth_failures.dart';

/// User-facing error situations the auth flow can surface. The blocs emit these
/// codes (never strings); the UI maps them to localized copy via
/// [authErrorMessage].
enum AuthErrorCode {
  sessionExpired,
  invalidCredentials,
  emailNotConfirmed,
  weakPassword,
  invalidCode,
  expiredCode,
  rateLimited,
  samePassword,
  signUpDisabled,
  accountNotFound,
  network,
  generic,
}

class AuthErrorMapper {
  static AuthErrorCode getCode(Failure failure) {
    return switch (failure) {
      UnauthenticatedFailure _ => AuthErrorCode.sessionExpired,
      InvalidCredentialsFailure _ => AuthErrorCode.invalidCredentials,
      EmailNotConfirmedFailure _ => AuthErrorCode.emailNotConfirmed,
      WeakPasswordFailure _ => AuthErrorCode.weakPassword,
      InvalidCodeFailure _ => AuthErrorCode.invalidCode,
      ExpiredCodeFailure _ => AuthErrorCode.expiredCode,
      RateLimitedFailure _ => AuthErrorCode.rateLimited,
      SamePasswordFailure _ => AuthErrorCode.samePassword,
      SignUpDisabledFailure _ => AuthErrorCode.signUpDisabled,
      AccountNotFoundFailure _ => AuthErrorCode.accountNotFound,
      NetworkFailure _ => AuthErrorCode.network,
      _ => AuthErrorCode.generic,
    };
  }
}

/// Turns an [AuthErrorCode] into localized copy. Lives in the presentation
/// layer because it needs an [AppLocalizations] from a widget.
String authErrorMessage(AppLocalizations l10n, AuthErrorCode code) =>
    switch (code) {
      AuthErrorCode.sessionExpired => l10n.authErrorSessionExpired,
      AuthErrorCode.invalidCredentials => l10n.authErrorInvalidCredentials,
      AuthErrorCode.emailNotConfirmed => l10n.authErrorEmailNotConfirmed,
      AuthErrorCode.weakPassword => l10n.authErrorWeakPassword,
      AuthErrorCode.invalidCode => l10n.authErrorInvalidCode,
      AuthErrorCode.expiredCode => l10n.authErrorExpiredCode,
      AuthErrorCode.rateLimited => l10n.authErrorRateLimited,
      AuthErrorCode.samePassword => l10n.authErrorSamePassword,
      AuthErrorCode.signUpDisabled => l10n.authErrorSignUpDisabled,
      AuthErrorCode.accountNotFound => l10n.authErrorAccountNotFound,
      AuthErrorCode.network => l10n.authErrorNetwork,
      AuthErrorCode.generic => l10n.authErrorGeneric,
    };
