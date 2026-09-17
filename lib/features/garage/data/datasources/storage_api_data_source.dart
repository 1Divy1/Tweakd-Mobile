import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/network/auth_interceptor.dart';
import '../../../../core/network/rate_limit_interceptor.dart';
import '../../../../core/network/rate_limit_notifier.dart';
import '../models/storage_models.dart';

@lazySingleton
class StorageApiDataSource {
  late final Dio _dio;

  StorageApiDataSource(
    SupabaseClient supabaseClient,
    RateLimitNotifier rateLimitNotifier,
  ) {
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
    _dio.interceptors.add(RateLimitInterceptor(rateLimitNotifier));
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => debugPrint('🗄️  STORAGE DIO: $object'),
      ),
    );
  }

  Future<UploadUrlResponseModel> getCoverUploadUrl(String carId) async {
    try {
      final response = await _dio.get('/cars/$carId/cover');
      return UploadUrlResponseModel.fromJson(response.data as Map<String, dynamic>);
    }
    on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<UploadUrlResponseModel> getGalleryUploadUrl(String carId) async {
    try {
      final response = await _dio.get('/cars/$carId/gallery');
      return UploadUrlResponseModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<ModUploadUrlsResponseModel> getModificationUploadUrls(
    String carId,
    String modId,
    List<Map<String, String>> files,
  ) async {
    try {
      final response = await _dio.post(
        '/cars/$carId/modifications/$modId/upload-urls',
        data: {'files': files},
      );
      return ModUploadUrlsResponseModel.fromJson(
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
    if (statusCode == 429) {
      return tooManyRequestsFrom(e.response);
    }
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
