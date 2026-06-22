import 'package:car_social_media_app/l10n/app_localizations.dart';

/// Username rules mirror the backend contract: 3–30 chars, must start with a
/// lowercase letter, end alphanumeric, only `a-z 0-9 . _`, and no `__` / `..`.
final RegExp _usernameAllowed =
    RegExp(r'^[a-z](?!.*[_.]{2})[a-z0-9._]*[a-z0-9]$');
const int usernameMinLength = 3;
const int usernameMaxLength = 30;

/// The ways a handle can fail local format validation. The presentation layer
/// turns these into localized copy via [usernameValidationMessage]; the rule
/// logic itself stays free of user-facing strings.
enum UsernameValidationError { empty, tooShort, tooLong, invalidChars }

/// Returns the format error for [username], or null when it is a well-formed
/// handle. Format only — uniqueness is checked separately against the backend.
UsernameValidationError? validateOnboardingUsername(String username) {
  if (username.isEmpty) return UsernameValidationError.empty;
  if (username.length < usernameMinLength) {
    return UsernameValidationError.tooShort;
  }
  if (username.length > usernameMaxLength) {
    return UsernameValidationError.tooLong;
  }
  if (!_usernameAllowed.hasMatch(username)) {
    return UsernameValidationError.invalidChars;
  }
  return null;
}

/// Maps a [UsernameValidationError] to its localized message. Lives in the
/// presentation layer because it needs an [AppLocalizations] from a widget.
String usernameValidationMessage(
  AppLocalizations l10n,
  UsernameValidationError error,
) =>
    switch (error) {
      UsernameValidationError.empty => l10n.onboardingUsernameErrorEmpty,
      UsernameValidationError.tooShort =>
        l10n.onboardingUsernameErrorTooShort(usernameMinLength),
      UsernameValidationError.tooLong =>
        l10n.onboardingUsernameErrorTooLong(usernameMaxLength),
      UsernameValidationError.invalidChars =>
        l10n.onboardingUsernameErrorInvalidChars,
    };
