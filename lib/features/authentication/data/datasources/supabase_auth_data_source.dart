import 'package:car_social_media_app/features/authentication/data/models/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@lazySingleton
class SupabaseAuthDataSource {
  final SupabaseClient client;

  SupabaseAuthDataSource(this.client);

  Session? get currentSession => client.auth.currentSession;

  Future<void> logOut() async {
    await client.auth.signOut();
  }

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

    GoogleSignInAccount? googleUser = await googleSignIn.attemptLightweightAuthentication();    
    if (googleUser == null) {
      
      // Check if the device supports the manual sign-in method (popup)
      if (googleSignIn.supportsAuthenticate()) {
        print("Supports authenticate");
        try {
          // Open the Google OAuth popup
          googleUser = await googleSignIn.authenticate();
        } 
        catch (e) {
          throw AuthException('The authentication failed or was cancelled: $e');
        }
      } 
      else {
        throw AuthException('The manual sign-in method is not supported on this device.');
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
    final authResponse = await client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: authorization.accessToken,
    );

    // Extract user information from the Supabase auth response and return it as a UserModel
    return UserModel.fromSupabase(authResponse.user!);
  }

  Future<UserModel> emailPasswordSignIn(String email, String password) async {
    final res = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    return UserModel.fromSupabase(res.user!);
  }
}