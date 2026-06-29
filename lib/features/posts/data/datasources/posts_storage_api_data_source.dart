import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/network/auth_interceptor.dart';
import '../models/post_upload_models.dart';

/// Talks to the storage module (`$API_BASE_URL/api/storage`) to mint presigned
/// R2 upload URLs for a post's images. Mirrors the garage storage data source.
@lazySingleton
class PostsStorageApiDataSource {
  late final Dio _dio;

  PostsStorageApiDataSource(SupabaseClient supabaseClient) {
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
        logPrint: (object) => debugPrint('🗄️  POST STORAGE DIO: $object'),
      ),
    );
  }

  /// Requests [count] presigned upload slots (1–10) for the post's WebP images.
  Future<PostUploadUrlsResponseModel> getImageUploadUrls(
    String postId,
    int count,
  ) async {
    try {
      final response = await _dio.post(
        '/posts/$postId/upload-urls',
        data: {'count': count},
      );
      return PostUploadUrlsResponseModel.fromJson(
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
      return ServerException('Server error while generating upload URLs.');
    }
    return ApiException(
      statusCode: statusCode,
      message: e.message ?? 'Failed to get upload URLs.',
    );
  }
}
