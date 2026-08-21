import 'user.dart';

/// What happened after a sign-up attempt.
///
/// [requiresEmailConfirmation] true means the account was created (or already
/// existed — the two are indistinguishable by design) and a confirmation email
/// went out; there is no session yet, so [user] is null. False means the
/// session is live and [user] is populated.
class SignUpResultEntity {
  final bool requiresEmailConfirmation;
  final UserEntity? user;

  const SignUpResultEntity({
    required this.requiresEmailConfirmation,
    this.user,
  });
}
