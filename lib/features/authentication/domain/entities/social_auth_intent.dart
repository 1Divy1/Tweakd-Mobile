import 'package:equatable/equatable.dart';

/// Which screen a Google / Apple sign-in was started from.
///
/// Supabase creates an account the first time it sees a social identity, no
/// matter where the button was tapped, so the app has to say which one it meant:
///
/// * [SignUpIntent] — the sign-up page. The terms were accepted there, so the
///   account is marked as registered (`profiles.terms_accepted_at`), together
///   with the optional analytics choice made on the same page.
/// * [SignInIntent] — the login page. Only an account that went through
///   sign-up may get in; one Supabase created just now is discarded and the
///   attempt fails with "no account".
sealed class SocialAuthIntent extends Equatable {
  const SocialAuthIntent();

  @override
  List<Object?> get props => [];
}

class SignInIntent extends SocialAuthIntent {
  const SignInIntent();
}

class SignUpIntent extends SocialAuthIntent {
  /// The optional "share usage analytics" box on the sign-up page.
  final bool analyticsConsent;

  const SignUpIntent({required this.analyticsConsent});

  @override
  List<Object?> get props => [analyticsConsent];
}
