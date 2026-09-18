import '../../../../core/error/base_failures.dart';

class UnauthenticatedFailure extends Failure {
  const UnauthenticatedFailure([
    String message = 'You are not logged in. Please authenticate first.',
  ]) : super(message: message);
}

/// Wrong password or unknown email — deliberately not distinguished, so the
/// sign-in form cannot be used to find out which addresses have accounts.
class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([
    String message = 'The email or password is incorrect.',
  ]) : super(message: message);
}

/// The account exists but its email was never confirmed.
class EmailNotConfirmedFailure extends Failure {
  const EmailNotConfirmedFailure([
    String message = 'This email address has not been confirmed yet.',
  ]) : super(message: message);
}

/// Supabase rejected the password against its server-side policy.
class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure([
    String message = 'That password is too weak.',
  ]) : super(message: message);
}

/// A one-time code was wrong or already used.
class InvalidCodeFailure extends Failure {
  const InvalidCodeFailure([
    String message = 'That code is not valid.',
  ]) : super(message: message);
}

/// A one-time code is past its expiry window.
class ExpiredCodeFailure extends Failure {
  const ExpiredCodeFailure([
    String message = 'That code has expired.',
  ]) : super(message: message);
}

/// Supabase's email-send or request rate limit kicked in.
class RateLimitedFailure extends Failure {
  const RateLimitedFailure([
    String message = 'Too many attempts. Please wait a moment and try again.',
  ]) : super(message: message);
}

/// The new password matches the current one.
class SamePasswordFailure extends Failure {
  const SamePasswordFailure([
    String message = 'The new password must be different from the old one.',
  ]) : super(message: message);
}

/// Email/password sign-ups are switched off for the project.
class SignUpDisabledFailure extends Failure {
  const SignUpDisabledFailure([
    String message = 'Sign-ups are currently disabled.',
  ]) : super(message: message);
}

/// A social sign-in from the login page found no registered account. Sign-in
/// never creates accounts — the user has to go through sign-up.
class AccountNotFoundFailure extends Failure {
  const AccountNotFoundFailure([
    String message = 'There is no account for this sign-in yet.',
  ]) : super(message: message);
}
