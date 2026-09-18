import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthInterceptor extends Interceptor {
  final SupabaseClient supabaseClient;

  AuthInterceptor(this.supabaseClient);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final auth = supabaseClient.auth;

    // A cold start restores the saved session as-is and refreshes it in the
    // background, and the launch fires its first requests right away — so an
    // app reopened after the access token's hour is up would send a dead JWT
    // and get a 401. Wait for the refresh instead, the same way Supabase's own
    // clients do before a query. Concurrent requests share one refresh (the
    // SDK de-duplicates it).
    if (auth.currentSession?.isExpired ?? false) {
      try {
        await auth.refreshSession();
      } catch (e) {
        // Offline or a revoked token: send what we have and let the response
        // (a network error or a 401) take the usual error path.
        debugPrint('Token refresh before request failed: ${e.runtimeType}');
      }
    }

    final token = auth.currentSession?.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
