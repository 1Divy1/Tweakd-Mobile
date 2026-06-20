import 'package:car_social_media_app/features/authentication/data/exceptions/auth_exceptions.dart';
import 'package:car_social_media_app/features/authentication/data/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/base_exceptions.dart';

@lazySingleton
class SupabaseAuthDataSource {
  final SupabaseClient supabaseClient;

  SupabaseAuthDataSource(this.supabaseClient);

  Session? get currentSession => supabaseClient.auth.currentSession;

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
    await supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );

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

    try {
      await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: authorization.accessToken,
      );
    } on AuthException catch (e) {
      debugPrint('Supabase signInWithIdToken error: $e');
      throw ServerException(e.message);
    }

    return checkAuthStatus();
  }
}
