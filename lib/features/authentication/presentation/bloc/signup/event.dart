import 'package:equatable/equatable.dart';

abstract class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object?> get props => [];
}

/// Create the account. The form has already checked the email shape and the
/// password policy by the time this is dispatched.
class SignUpSubmitted extends SignUpEvent {
  final String email;
  final String password;
  final bool analyticsConsent;

  const SignUpSubmitted({
    required this.email,
    required this.password,
    required this.analyticsConsent,
  });

  // `password` is deliberately left out of props so it never lands in bloc
  // observer logs; email alone already distinguishes two submissions.
  @override
  List<Object?> get props => [email, analyticsConsent];
}

/// Confirm the new account with the code from the sign-up email.
class SignUpCodeSubmitted extends SignUpEvent {
  final String email;
  final String code;

  const SignUpCodeSubmitted({required this.email, required this.code});

  @override
  List<Object?> get props => [email, code];
}

/// Send the confirmation email again from the "check your inbox" screen.
class ConfirmationEmailResendRequested extends SignUpEvent {
  final String email;

  const ConfirmationEmailResendRequested(this.email);

  @override
  List<Object?> get props => [email];
}
