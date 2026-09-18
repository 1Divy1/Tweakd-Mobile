import 'package:equatable/equatable.dart';

import '../../domain/entities/social_auth_intent.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

// Logout
class LogoutRequested extends AuthEvent {}

// OAuth Events. [intent] says which page the button was on: sign-in only
// admits an existing account, sign-up is the one place accounts are created.
class GoogleLoginRequested extends AuthEvent {
  final SocialAuthIntent intent;

  const GoogleLoginRequested(this.intent);

  @override
  List<Object?> get props => [intent];
}

class AppleLoginRequested extends AuthEvent {
  final SocialAuthIntent intent;

  const AppleLoginRequested(this.intent);

  @override
  List<Object?> get props => [intent];
}

/// The Android Apple flow's session arrived through its deep link.
class AppleRedirectSignedIn extends AuthEvent {
  final SocialAuthIntent intent;

  const AppleRedirectSignedIn(this.intent);

  @override
  List<Object?> get props => [intent];
}

// Classic signup
class EmailPasswordLoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const EmailPasswordLoginSubmitted({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
