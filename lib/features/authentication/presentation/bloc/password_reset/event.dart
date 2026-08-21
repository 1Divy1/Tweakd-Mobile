import 'package:equatable/equatable.dart';

abstract class PasswordResetEvent extends Equatable {
  const PasswordResetEvent();

  @override
  List<Object?> get props => [];
}

/// Step 1 — email a recovery code.
class ResetCodeRequested extends PasswordResetEvent {
  final String email;

  const ResetCodeRequested(this.email);

  @override
  List<Object?> get props => [email];
}

/// Step 2 — exchange the code for a recovery session.
class ResetCodeSubmitted extends PasswordResetEvent {
  final String email;
  final String code;

  const ResetCodeSubmitted({required this.email, required this.code});

  @override
  List<Object?> get props => [email, code];
}

/// Step 3 — set the new password on the recovery session.
class NewPasswordSubmitted extends PasswordResetEvent {
  final String password;

  const NewPasswordSubmitted(this.password);

  // The password stays out of props so it cannot surface in bloc logs.
  @override
  List<Object?> get props => [];
}
