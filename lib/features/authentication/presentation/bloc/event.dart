import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// OAuth Events
class GoogleLoginRequested extends AuthEvent {}
class AppleLoginRequested extends AuthEvent {}

class EmailPasswordLoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const EmailPasswordLoginSubmitted({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}