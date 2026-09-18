import 'package:equatable/equatable.dart';

/// Outcome of re-checking, in the background, a session the app launched on
/// optimistically. Only the two outcomes that must move the user carry a
/// state; everything else — confirmed, offline, server hiccup — stays
/// [SessionCheckPending].
sealed class SessionCheckState extends Equatable {
  const SessionCheckState();

  @override
  List<Object?> get props => [];
}

/// Not resolved yet, confirmed, or unresolvable right now. Nothing to do.
class SessionCheckPending extends SessionCheckState {
  const SessionCheckPending();
}

/// The profile still needs onboarding.
class SessionCheckRequiresOnboarding extends SessionCheckState {
  const SessionCheckRequiresOnboarding();
}

/// The session is gone: the profile row no longer exists, or the server
/// refused the saved refresh token.
class SessionCheckSignedOut extends SessionCheckState {
  const SessionCheckSignedOut();
}
