/// Username rules mirror the backend contract: 3–30 chars, must start with a
/// lowercase letter, end alphanumeric, only `a-z 0-9 . _`, and no `__` / `..`.
final RegExp _usernameAllowed =
    RegExp(r'^[a-z](?!.*[_.]{2})[a-z0-9._]*[a-z0-9]$');
const int _usernameMinLength = 3;
const int _usernameMaxLength = 30;

/// Returns an error string when [username] is invalid, or null when it is a
/// well-formed handle. Format only — uniqueness is checked separately against
/// the backend.
String? validateOnboardingUsername(String username) {
  if (username.isEmpty) return 'Please choose a handle.';
  if (username.length < _usernameMinLength) {
    return 'Handle must be at least $_usernameMinLength characters.';
  }
  if (username.length > _usernameMaxLength) {
    return 'Handle must be at most $_usernameMaxLength characters.';
  }
  if (!_usernameAllowed.hasMatch(username)) {
    return 'Use lowercase letters, numbers, dots (.) and underscores (_).';
  }
  return null;
}
