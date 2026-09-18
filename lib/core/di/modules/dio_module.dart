import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../network/auth_interceptor.dart';
import '../../network/rate_limit_interceptor.dart';
import '../../network/rate_limit_notifier.dart';

@module
abstract class DioModule {
  @lazySingleton
  Dio dio(SupabaseClient supabaseClient, RateLimitNotifier rateLimitNotifier) {
    final host = dotenv.env['API_BASE_URL'] ?? '';
    final dio = Dio(
      BaseOptions(
        baseUrl: '$host/api/v1',
        // The backend runs on Cloud Run with no minimum instances, so the
        // first request after it has idled pays a JVM cold start. Generous
        // timeouts ride that out.
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(AuthInterceptor(supabaseClient));
    dio.interceptors.add(RateLimitInterceptor(rateLimitNotifier));
    // Debug only: it prints every request and response body, and in a profile
    // or release build that is real work on every call — the launch's feed
    // page alone is a sizeable JSON dump.
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: false,
          responseHeader: false,
          requestBody: true,
          responseBody: true,
          logPrint: (object) => debugPrint('🌐 DIO: $object'),
        ),
      );
    }

    return dio;
  }
}
