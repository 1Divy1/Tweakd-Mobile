import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tweakd/features/authentication/data/exceptions/auth_exceptions.dart';
import 'package:tweakd/features/authentication/data/models/apple_sign_in_result_model.dart';
import 'package:tweakd/features/authentication/data/models/sign_up_result_model.dart';
import 'package:tweakd/features/authentication/data/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/base_exceptions.dart';

/// Deep link Supabase redirects to once the user taps the button in the
/// confirmation email. Must be listed under Auth → URL Configuration →
/// Redirect URLs in the Supabase dashboard, and registered in
/// `AndroidManifest.xml` / `Info.plist`, or the link will not reopen the app.
const String kSignUpEmailRedirect = 'tweakd://signup-callback';

/// Deep link Supabase redirects to at the end of the Android Apple OAuth flow.
/// Deliberately separate from [kSignUpEmailRedirect] so the working
/// email-confirmation path is left untouched. Must be listed under Auth → URL
/// Configuration → Redirect URLs in the Supabase dashboard, and matched by an
/// intent filter in `AndroidManifest.xml`. iOS needs no entry: it runs the
/// native flow and never opens this link.
const String kAppleOAuthRedirect = 'tweakd://login-callback';

@lazySingleton
class SupabaseAuthDataSource {
  final SupabaseClient supabaseClient;

  SupabaseAuthDataSource(this.supabaseClient);

  Session? get currentSession => supabaseClient.auth.currentSession;

  /// Fires whenever Supabase establishes a session this app did not ask for
  /// directly — in practice, when the confirmation deep link is opened and the
  /// SDK exchanges the PKCE code for a session in the background. The root
  /// [AuthBloc] listens so the UI can move on without the user tapping again.
  Stream<void> get onSignedIn => supabaseClient.auth.onAuthStateChange
      .where((change) => change.event == AuthChangeEvent.signedIn)
      .map((_) {});

  /// Translates a Supabase [AuthException] into one of the app's own
  /// exceptions. Every call into `supabaseClient.auth` funnels through here so
  /// no package-level exception can escape the data layer.
  ///
  /// Codes come from gotrue's [ErrorCode] list; `invalid_credentials` is not in
  /// that enum yet, so it is matched as a raw string.
  Never _mapAuthException(AuthException e) {
    // Never log `e` wholesale on auth paths — messages can echo submitted
    // values. The code alone is enough to debug with.
    debugPrint('Supabase auth error (code: ${e.code}, status: ${e.statusCode})');

    if (e is AuthWeakPasswordException) {
      throw WeakPasswordException(message: e.message, reasons: e.reasons);
    }
    // Carries no `code`, so it has to be matched by type. Reaching this from
    // the reset flow means the recovery session lapsed before the new password
    // was saved — the UI uses it to send the user back to sign in.
    if (e is AuthSessionMissingException) {
      throw NoActiveSessionException();
    }
    // The request never reached Supabase; surfacing it as a server error would
    // tell the user to retry something that is not their fault to fix.
    if (e is AuthRetryableFetchException) {
      throw NetworkException();
    }

    switch (e.code) {
      case 'invalid_credentials':
        throw InvalidCredentialsException();
      case 'email_not_confirmed':
        throw EmailNotConfirmedException();
      case 'weak_password':
        throw WeakPasswordException(message: e.message);
      case 'otp_expired':
        throw ExpiredOtpException();
      case 'same_password':
        throw SamePasswordException();
      case 'over_email_send_rate_limit':
      case 'over_request_rate_limit':
        throw RateLimitedException();
      case 'signup_disabled':
      case 'email_provider_disabled':
        throw SignUpDisabledException();
      case 'user_banned':
        throw ServerException(
          'This account has been suspended. Please contact support.',
        );
      case 'session_missing':
      case 'session_expired':
      case 'session_not_found':
        throw NoActiveSessionException();
    }

    // A wrong code comes back as a 403 with no dedicated code, and
    // `validation_failed` covers malformed input on the same endpoints.
    if (e.statusCode == '403' || e.code == 'validation_failed') {
      throw InvalidOtpException();
    }
    if (e.statusCode == '429') {
      throw RateLimitedException();
    }
    throw ServerException(e.message);
  }

  /// Runs [action], converting any Supabase [AuthException] into an app
  /// exception. Non-auth errors (network, decoding) surface as [ServerException].
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthException catch (e) {
      _mapAuthException(e);
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on NoActiveSessionException {
      rethrow;
    } catch (e) {
      debugPrint('Unexpected Supabase auth failure: ${e.runtimeType}');
      throw ServerException('An unexpected error occurred. Please try again.');
    }
  }

  /// Logs the user out and wipes every locally cached credential so the next
  /// launch behaves as if the user had never signed in.
  ///
  /// This covers three layers:
  /// 1. Supabase — clears the in-memory session and (via the configured
  ///    [LocalStorage]) the persisted access/refresh token.
  /// 2. Google Sign-In — drops the cached Google account so a subsequent
  ///    sign-in attempt cannot silently re-authenticate the same user.
  /// 3. Secure storage — a final defensive sweep that removes anything left
  ///    behind in flutter_secure_storage.
  Future<void> logOut() async {
    try {
      await supabaseClient.auth.signOut();

      // Google sign-out is best-effort: it can throw if Google Sign-In was
      // never initialized (e.g. an email/password user), which must not block
      // the logout flow.
      try {
        await GoogleSignIn.instance.signOut();
      } catch (e) {
        debugPrint('Google sign-out skipped: $e');
      }

      // Guarantee no token survives, regardless of which auth path was used.
      await const FlutterSecureStorage().deleteAll();
    } on AuthException catch (e) {
      debugPrint('Supabase signOut error: $e');
      throw ServerException(e.message);
    } catch (e) {
      debugPrint('Unexpected error during logOut: $e');
      throw ServerException('Failed to log out. Please try again.');
    }
  }

  Future<UserModel> checkAuthStatus() async {
    // Check if there is an active session
    final session = supabaseClient.auth.currentSession;
    if (session == null) {
      throw NoActiveSessionException();
    }

    try {
      final profileData = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', session.user.id)
          .single();

      return UserModel.fromProfile(session.user, profileData);
    } catch (e) {
      // If a local session exists, but the user could not be found in the database, we force delete the local session
      if (e is PostgrestException && e.code == 'PGRST116') {
        await supabaseClient.auth.signOut();
        throw ServerException(
          'The session expired or is invalid. Please log in again.',
        );
      }
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  // Classic Email/Password Sign-In Method
  Future<UserModel> emailPasswordSignIn(String email, String password) async {
    await _guard(
      () => supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      ),
    );

    return checkAuthStatus();
  }

  /// Registers a new account.
  ///
  /// With "Confirm email" on (the project's current setting) Supabase returns a
  /// user but **no session** — the account is dormant until the confirmation
  /// link is opened. If the address already belongs to an account, Supabase
  /// returns that same shape with an empty `identities` list rather than an
  /// error; this method deliberately reports the identical result either way so
  /// the UI cannot be used to discover which addresses are registered.
  Future<SignUpResultModel> signUp(String email, String password) async {
    final response = await _guard(
      () => supabaseClient.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: kSignUpEmailRedirect,
      ),
    );

    // Only reachable if email confirmation is switched off project-wide.
    if (response.session != null) {
      return SignUpResultModel(
        requiresEmailConfirmation: false,
        user: await checkAuthStatus(),
      );
    }

    return const SignUpResultModel(requiresEmailConfirmation: true);
  }

  /// Confirms a new account with the code from the sign-up email.
  ///
  /// The confirm-signup template renders `{{ .Token }}`, so this — not the
  /// deep link — is how an account gets activated. A typed code also works when
  /// the mail is read on another device, which a PKCE link cannot.
  Future<UserModel> verifySignUpCode(String email, String code) async {
    final response = await _guard(
      () => supabaseClient.auth.verifyOTP(
        email: email,
        token: code,
        type: OtpType.signup,
      ),
    );

    if (response.session == null) {
      throw InvalidOtpException();
    }

    return checkAuthStatus();
  }

  /// Sends the confirmation email again for an account that has not been
  /// verified yet.
  Future<void> resendSignUpEmail(String email) async {
    await _guard(
      () => supabaseClient.auth.resend(
        type: OtpType.signup,
        email: email,
        emailRedirectTo: kSignUpEmailRedirect,
      ),
    );
  }

  /// Step 1 of the password reset: emails a recovery code.
  ///
  /// No `redirectTo` is passed — the flow is code-based, so no deep link is
  /// involved and the code can be typed on any device. Supabase does not report
  /// whether the address exists, which is what keeps this endpoint from being
  /// an account-enumeration oracle.
  Future<void> requestPasswordReset(String email) async {
    await _guard(() => supabaseClient.auth.resetPasswordForEmail(email));
  }

  /// Step 2: exchanges the emailed code for a short-lived recovery session.
  Future<void> verifyPasswordResetCode(String email, String code) async {
    final response = await _guard(
      () => supabaseClient.auth.verifyOTP(
        email: email,
        token: code,
        type: OtpType.recovery,
      ),
    );

    if (response.session == null) {
      throw InvalidOtpException();
    }
  }

  /// Step 3: sets the new password on the recovery session, then revokes every
  /// *other* session so anyone signed in elsewhere with the old password is
  /// kicked out. This device stays signed in.
  Future<UserModel> updatePassword(String newPassword) async {
    if (supabaseClient.auth.currentSession == null) {
      throw NoActiveSessionException();
    }

    await _guard(
      () => supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      ),
    );

    try {
      await supabaseClient.auth.signOut(scope: SignOutScope.others);
    } catch (e) {
      // Best-effort: the password is already changed, so a failure here must
      // not present itself to the user as a failed reset.
      debugPrint('Could not revoke other sessions: ${e.runtimeType}');
    }

    return checkAuthStatus();
  }

  // OAuth Sign-In Methods
  Future<UserModel> googleSignIn() async {
    final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID']!;
    final iosClientId = dotenv.env['GOOGLE_IOS_CLIENT_ID']!;
    final scopes = ['email', 'profile'];

    // Initialize Google Sign-In
    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize(
      serverClientId: webClientId,
      clientId: iosClientId,
    );

    GoogleSignInAccount? googleUser = await googleSignIn
        .attemptLightweightAuthentication();
    if (googleUser == null) {
      if (!googleSignIn.supportsAuthenticate()) {
        throw ServerException('Google Sign-In is not supported on this device.');
      }
      try {
        googleUser = await googleSignIn.authenticate();
      } catch (e) {
        debugPrint('google_sign_in authenticate() error: $e');
        throw ServerException('Google Sign-In failed or was cancelled.');
      }
    }

    final authorization =
        await googleUser.authorizationClient.authorizationForScopes(scopes) ??
        await googleUser.authorizationClient.authorizeScopes(scopes);

    final idToken = googleUser.authentication.idToken;
    if (idToken == null) {
      throw ServerException('No ID token received from Google Sign-In.');
    }

    await _guard(
      () => supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: authorization.accessToken,
      ),
    );

    return checkAuthStatus();
  }

  /// Signs in with Apple.
  ///
  /// Apple ships a native Sign in with Apple SDK only for its own platforms, so
  /// this is really two flows:
  ///
  /// * **iOS** — the native ID-token flow. `sign_in_with_apple` shows the system
  ///   sheet and the returned ID token is exchanged for a Supabase session
  ///   in-process, so the user is fully resolved before this returns. The nonce
  ///   goes to Apple hashed and to Supabase raw: Apple embeds the hash in the
  ///   token, and Supabase re-hashes the raw value to prove the token was minted
  ///   for this exact request and cannot be replayed.
  /// * **Everything else (Android)** — no Apple SDK exists, so it is the
  ///   browser-based OAuth flow. `signInWithOAuth` only launches the browser and
  ///   returns; the session appears later, when Apple redirects back through
  ///   [kAppleOAuthRedirect] and the SDK handles the deep link. The root
  ///   [AuthBloc] picks that up via [onSignedIn], so there is nothing to return
  ///   here but "pending".
  Future<AppleSignInResultModel> appleSignIn() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      final launched = await _guard(
        () => supabaseClient.auth.signInWithOAuth(
          OAuthProvider.apple,
          redirectTo: kAppleOAuthRedirect,
          authScreenLaunchMode: LaunchMode.externalApplication,
        ),
      );
      // False means the browser never opened, so no redirect is coming and the
      // caller would otherwise wait forever for a session that cannot arrive.
      if (!launched) {
        throw ServerException('Could not open the Apple sign-in page.');
      }
      return const AppleSignInResultModel(awaitingRedirect: true);
    }

    final rawNonce = supabaseClient.auth.generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final AuthorizationCredentialAppleID credential;
    try {
      credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );
    } on SignInWithAppleException catch (e) {
      // Never log `e` wholesale on auth paths — messages can echo account
      // details. A plain cancel lands here too; it is reported the same way
      // Google's is, so both social buttons behave identically.
      debugPrint('Apple sign-in error: ${e.runtimeType}');
      throw ServerException('Apple Sign-In failed or was cancelled.');
    }

    final idToken = credential.identityToken;
    if (idToken == null) {
      throw ServerException('No ID token received from Apple Sign-In.');
    }

    await _guard(
      () => supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      ),
    );

    await _persistAppleFullName(credential);

    return AppleSignInResultModel(
      awaitingRedirect: false,
      user: await checkAuthStatus(),
    );
  }

  /// Copies the name Apple supplies into the Supabase user metadata, under the
  /// same `full_name` key Google populates, so onboarding can prefill its name
  /// field the same way regardless of which provider the account came from.
  ///
  /// Apple sends the name **only on the very first sign-in ever** and never
  /// again, and it rides on the credential rather than the ID token — so by the
  /// time the `handle_new_user` trigger has inserted the profile row there is
  /// nothing for it to read. This is the only moment the name is available.
  ///
  /// Best-effort: the session is already live by now, so a failure here must not
  /// turn a successful sign-in into a failed one. The user just types their name
  /// during onboarding instead.
  Future<void> _persistAppleFullName(
    AuthorizationCredentialAppleID credential,
  ) async {
    final fullName = [credential.givenName, credential.familyName]
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .join(' ');
    // Empty on every sign-in after the first — skip rather than overwrite a
    // name that is already stored with a blank.
    if (fullName.isEmpty) return;

    try {
      await supabaseClient.auth.updateUser(
        UserAttributes(data: {'full_name': fullName}),
      );
    } catch (e) {
      debugPrint('Could not persist Apple full name: ${e.runtimeType}');
    }
  }
}
