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
        // Render free-tier instances cold-start (~30-60s) after idling,
        // so allow generous timeouts to ride out the first wake-up request.
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
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: false,
        responseHeader: false,
        requestBody: true,
        responseBody: true,
        logPrint: (object) => debugPrint('🌐 DIO: $object'),
      ),
    );

    return dio;
  }
}
