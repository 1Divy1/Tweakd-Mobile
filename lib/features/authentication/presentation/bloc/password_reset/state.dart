import 'package:equatable/equatable.dart';

import '../../../domain/entities/user.dart';
import '../../utils/auth_error_mapper.dart';

abstract class PasswordResetState extends Equatable {
  const PasswordResetState();

  @override
  List<Object?> get props => [];
}

class PasswordResetInitial extends PasswordResetState {}

class PasswordResetLoading extends PasswordResetState {}

/// A recovery code was emailed. Supabase does not disclose whether the address
/// has an account, so this state says nothing about that either.
class ResetCodeSent extends PasswordResetState {
  final String email;

  /// Increments per send so a resend re-triggers the UI confirmation.
  final int attempt;

  const ResetCodeSent({required this.email, required this.attempt});

  @override
  List<Object?> get props => [email, attempt];
}

/// The code was accepted; a recovery session is now active and the new password
/// can be set.
class ResetCodeVerified extends PasswordResetState {}

/// The new password is saved and every other session has been revoked.
class PasswordResetCompleted extends PasswordResetState {
  final UserEntity user;

  const PasswordResetCompleted(this.user);

  @override
  List<Object?> get props => [user];
}

class PasswordResetFailed extends PasswordResetState {
  final AuthErrorCode code;

  const PasswordResetFailed(this.code);

  @override
  List<Object?> get props => [code];
}
