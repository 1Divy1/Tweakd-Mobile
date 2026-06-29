import 'package:car_social_media_app/l10n/app_localizations.dart';

import '../../../../core/error/base_failures.dart';
import '../../../profile/domain/failures/profile_failures.dart';

/// User-facing error situations the onboarding flow can surface. Blocs emit
/// these codes (never strings); the UI maps them to localized copy via
/// [onboardingErrorMessage].
enum OnboardingErrorCode {
  loadFailed,
  usernameTaken,
  sessionExpired,
  invalidUsername,
  generic,
}

/// Maps onboarding submit failures to an [OnboardingErrorCode]. The submit
/// reuses the profile failures (it hits `POST /profile/onboarding`), so
/// username-specific cases are handled here before the generic fallback.
class OnboardingErrorMapper {
  static OnboardingErrorCode getCode(Failure failure) {
    if (failure is UsernameTakenFailure) {
      return OnboardingErrorCode.usernameTaken;
    }
    if (failure is UnauthenticatedFailure) {
      return OnboardingErrorCode.sessionExpired;
    }
    if (failure is InvalidUsernameFailure) {
      return OnboardingErrorCode.invalidUsername;
    }
    return OnboardingErrorCode.generic;
  }
}

/// Turns an [OnboardingErrorCode] into localized copy. Lives in the
/// presentation layer because it needs an [AppLocalizations] from a widget.
String onboardingErrorMessage(AppLocalizations l10n, OnboardingErrorCode code) =>
    switch (code) {
      OnboardingErrorCode.loadFailed => l10n.onboardingErrorLoadFailed,
      OnboardingErrorCode.usernameTaken => l10n.onboardingErrorUsernameTaken,
      OnboardingErrorCode.sessionExpired => l10n.onboardingErrorSessionExpired,
      OnboardingErrorCode.invalidUsername =>
        l10n.onboardingErrorInvalidUsername,
      OnboardingErrorCode.generic => l10n.onboardingErrorGeneric,
    };
