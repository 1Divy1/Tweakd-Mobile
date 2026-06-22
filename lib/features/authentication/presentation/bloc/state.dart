import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';
import '../utils/auth_error_mapper.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Unauthenticated extends AuthState {}

class Authenticated extends AuthState {
  final UserEntity user;
  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthenticatedRequiresOnboarding extends AuthState {
  final UserEntity user;
  const AuthenticatedRequiresOnboarding(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final AuthErrorCode code;
  const AuthError(this.code);

  @override
  List<Object?> get props => [code];
}
