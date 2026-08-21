import 'package:equatable/equatable.dart';

import '../../../domain/entities/user.dart';
import '../../utils/auth_error_mapper.dart';

abstract class SignUpState extends Equatable {
  const SignUpState();

  @override
  List<Object?> get props => [];
}

class SignUpInitial extends SignUpState {}

class SignUpLoading extends SignUpState {}

/// The account was created (or the address already had one — the two are
/// indistinguishable on purpose) and a confirmation email went out. There is no
/// session yet.
class SignUpAwaitingConfirmation extends SignUpState {
  final String email;

  const SignUpAwaitingConfirmation(this.email);

  @override
  List<Object?> get props => [email];
}

/// Only reachable if email confirmation is switched off project-wide: the user
/// is already signed in.
class SignUpCompleted extends SignUpState {
  final UserEntity user;

  const SignUpCompleted(this.user);

  @override
  List<Object?> get props => [user];
}

/// The confirmation email was sent again.
class SignUpResendSucceeded extends SignUpState {
  /// Distinguishes consecutive resends so the UI shows the confirmation each
  /// time rather than swallowing an identical state.
  final int attempt;

  const SignUpResendSucceeded(this.attempt);

  @override
  List<Object?> get props => [attempt];
}

class SignUpFailed extends SignUpState {
  final AuthErrorCode code;

  const SignUpFailed(this.code);

  @override
  List<Object?> get props => [code];
}
