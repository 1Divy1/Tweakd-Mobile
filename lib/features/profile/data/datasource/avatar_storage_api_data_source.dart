import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/network/auth_interceptor.dart';
import '../models/avatar_upload_model.dart';

/// Talks to the storage module (`$API_BASE_URL/api/storage`) to mint a presigned
/// R2 upload URL for the current user's avatar. Mirrors
/// [PostsStorageApiDataSource] — same host, different path prefix (NOT under
/// `/public/api/v1`). The mint call is authed; the presigned PUT that follows is
/// not (it goes through [ImageService]'s bare Dio).
@lazySingleton
class AvatarStorageApiDataSource {
  late final Dio _dio;

  AvatarStorageApiDataSource(SupabaseClient supabaseClient) {
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
        logPrint: (object) => debugPrint('🗄️  AVATAR STORAGE DIO: $object'),
      ),
    );
  }

  /// Requests a presigned upload slot for the WebP avatar.
  Future<AvatarUploadSlotModel> getAvatarUploadSlot() async {
    try {
      final response = await _dio.get('/avatar');
      return AvatarUploadSlotModel.fromJson(
          response.data as Map<String, dynamic>);
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
      return ServerException('Server error while preparing the upload.');
    }
    return ApiException(
      statusCode: statusCode,
      message: e.message ?? 'Failed to prepare the avatar upload.',
    );
  }
}
