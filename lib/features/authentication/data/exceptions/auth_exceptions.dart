class DuplicateDataException implements Exception {}

class NoActiveSessionException implements Exception {
  final String message;
  NoActiveSessionException([
    this.message = 'No active session found. Please log in.',
  ]);
}

/// Wrong password, or an email that has no account. Supabase deliberately
/// returns the same error for both so the response cannot be used to probe
/// which addresses are registered — keep it that way when mapping upwards.
class InvalidCredentialsException implements Exception {
  final String message;
  InvalidCredentialsException([
    this.message = 'The email or password is incorrect.',
  ]);
}

/// The account exists but its email address was never confirmed.
class EmailNotConfirmedException implements Exception {
  final String message;
  EmailNotConfirmedException([
    this.message = 'This email address has not been confirmed yet.',
  ]);
}

/// Supabase rejected the password against its own server-side policy. [reasons]
/// carries gotrue's machine-readable reason list (e.g. `length`, `characters`).
class WeakPasswordException implements Exception {
  final String message;
  final List<String> reasons;
  WeakPasswordException({
    this.message = 'That password is too weak.',
    this.reasons = const [],
  });
}

/// A one-time code was wrong (or already used).
class InvalidOtpException implements Exception {
  final String message;
  InvalidOtpException([this.message = 'That code is not valid.']);
}

/// A one-time code was correct but is past its expiry window.
class ExpiredOtpException implements Exception {
  final String message;
  ExpiredOtpException([this.message = 'That code has expired.']);
}

/// Supabase's email-send or request rate limit kicked in.
class RateLimitedException implements Exception {
  final String message;
  RateLimitedException([
    this.message = 'Too many attempts. Please wait a moment and try again.',
  ]);
}

/// The new password is identical to the current one.
class SamePasswordException implements Exception {
  final String message;
  SamePasswordException([
    this.message = 'The new password must be different from the old one.',
  ]);
}

/// Email/password sign-ups are switched off for the Supabase project.
class SignUpDisabledException implements Exception {
  final String message;
  SignUpDisabledException([
    this.message = 'Sign-ups are currently disabled.',
  ]);
}

/// A social sign-in from the login page found no registered account for that
/// Google / Apple identity. Accounts are only ever created from the sign-up
/// page; the one Supabase made on the way in has already been discarded.
class AccountNotFoundException implements Exception {
  final String message;
  AccountNotFoundException([
    this.message = 'There is no account for this sign-in yet.',
  ]);
}
