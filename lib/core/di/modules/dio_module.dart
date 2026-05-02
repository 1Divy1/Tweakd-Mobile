import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../network/auth_interceptor.dart';

@module
abstract class DioModule {
  @lazySingleton
  Dio dio(SupabaseClient supabaseClient) {
    final host = dotenv.env['API_BASE_URL'] ?? '';
    final dio = Dio(
      BaseOptions(
        baseUrl: '$host/public/api/v1',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(AuthInterceptor(supabaseClient));
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => debugPrint('🌐 DIO: $object'),
      ),
    );

    return dio;
  }
}
