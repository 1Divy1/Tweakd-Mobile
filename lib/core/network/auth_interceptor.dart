import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthInterceptor extends Interceptor {
  final SupabaseClient supabaseClient;

  AuthInterceptor(this.supabaseClient);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = supabaseClient.auth.currentSession?.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
