import 'package:car_social_media_app/features/authentication/data/exceptions/auth_exceptions.dart';
import 'package:car_social_media_app/features/authentication/data/models/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/base_exceptions.dart';

@lazySingleton
class SupabaseAuthDataSource {
  final SupabaseClient supabaseClient;

  SupabaseAuthDataSource(this.supabaseClient);

  Session? get currentSession => supabaseClient.auth.currentSession;

  Future<void> logOut() async {
    await supabaseClient.auth.signOut();
  }

  Future<void> updateUsername(String newUsername) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      throw NoActiveSessionException();
    }

    try {
      await supabaseClient
          .from('profiles')
          .update({'username': newUsername})
          .eq('id', user.id);
    } 
    catch (e) {
      if (e.toString().contains('unique constraint') ||
          e.toString().contains('23505')) {
        throw DuplicateDataException();
      }
      throw ServerException('An error occurred while saving the username.');
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

      return UserModel.fromAuthAndProfile(
        authUser: session.user,
        profileData: profileData,
      );
    } 
    catch (e) {
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
    final res = await supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );

    return UserModel.fromSupabase(res.user!);
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
      // Check if the device supports the manual sign-in method (popup)
      if (googleSignIn.supportsAuthenticate()) {
        try {
          // Open the Google OAuth popup
          googleUser = await googleSignIn.authenticate();
        } 
        catch (e) {
          throw AuthException('The authentication failed or was cancelled: $e');
        }
      } 
      else {
        throw AuthException(
          'The manual sign-in method is not supported on this device.',
        );
      }
    }

    // Ask the user to grant the necessary permissions for the app to access their Google account information
    final authorization =
        await googleUser.authorizationClient.authorizationForScopes(scopes) ??
        await googleUser.authorizationClient.authorizeScopes(scopes);

    // Extracting the ID token from the Google Sign-In response
    final idToken = googleUser.authentication.idToken;
    if (idToken == null) {
      throw AuthException('No ID Token found.');
    }

    // Establishing auth connection between Supabase and the app
    final authResponse = await supabaseClient.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: authorization.accessToken,
    );

    // Extract user information from the Supabase auth response and return it as a UserModel
    return UserModel.fromSupabase(authResponse.user!);
  }
}
