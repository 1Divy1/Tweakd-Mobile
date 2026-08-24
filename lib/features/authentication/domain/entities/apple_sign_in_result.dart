import 'user.dart';

/// What happened after an Apple sign-in attempt.
///
/// Apple ships a native Sign in with Apple SDK only for its own platforms, so
/// the two platforms resolve at different times and this carries either shape:
///
/// * iOS runs the native ID-token flow in-process, so the session exists by the
///   time the call returns — [awaitingRedirect] is false and [user] is set.
/// * Android has no Apple SDK and must use the browser-based OAuth flow, which
///   only launches the browser. The session arrives later, via the deep link,
///   so [awaitingRedirect] is true and [user] is null.
class AppleSignInResultEntity {
  final bool awaitingRedirect;
  final UserEntity? user;

  const AppleSignInResultEntity({required this.awaitingRedirect, this.user});
}
