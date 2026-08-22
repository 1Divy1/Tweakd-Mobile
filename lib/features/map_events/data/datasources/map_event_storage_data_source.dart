import 'package:tweakd/core/error/base_exceptions.dart';
import 'package:tweakd/core/network/auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/map_event_list_models.dart';

/// The presigned-upload slot for an event's cover image.
///
/// The storage module lives at `$API_BASE_URL/api/storage`, a different base
/// from the `/api/v1` one `AbstractHTTP` is configured with, so — exactly as
/// the garage's storage data source does — this owns its own Dio with the same
/// `AuthInterceptor` bolted on.
///
/// The GET itself has **no ownership check** (any JWT gets a URL); the
/// enforcement is on `PATCH /map-events/{id}/cover`, which is organizer-scoped.
@lazySingleton
class MapEventStorageDataSource {
  late final Dio _dio;

  MapEventStorageDataSource(SupabaseClient supabaseClient) {
    final host = dotenv.env['API_BASE_URL'] ?? '';
    _dio = Dio(
      BaseOptions(
        baseUrl: '$host/api/storage',
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _dio.interceptors.add(AuthInterceptor(supabaseClient));
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => debugPrint('🗄️  STORAGE DIO: $object'),
      ),
    );
  }

  Future<MapEventCoverUploadModel> getCoverUploadUrl(String eventId) async {
    try {
      final response = await _dio.get('/events/$eventId/cover');
      return MapEventCoverUploadModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Exception _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkException();
    }
    final statusCode = e.response?.statusCode ?? 0;
    if (statusCode == 401) {
      return UnauthenticatedException('Authentication required.');
    }
    if (statusCode >= 500) {
      return ServerException('Server error while generating upload URL.');
    }
    return ApiException(
      statusCode: statusCode,
      message: e.message ?? 'Failed to get upload URL.',
    );
  }
}
