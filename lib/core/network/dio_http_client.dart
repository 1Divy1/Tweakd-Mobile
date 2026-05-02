import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../error/base_exceptions.dart';
import 'abstract_http.dart';

@LazySingleton(as: AbstractHTTP)
class DioHttpClient implements AbstractHTTP {
  final Dio dio;

  DioHttpClient(this.dio);

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    return _request(
      () => dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      ),
    );
  }

  @override
  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    return _request(
      () => dio.post(
        path,
        data: body,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      ),
    );
  }

  @override
  Future<dynamic> put(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    return _request(
      () => dio.put(
        path,
        data: body,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      ),
    );
  }

  @override
  Future<dynamic> patch(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    return _request(
      () => dio.patch(
        path,
        data: body,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      ),
    );
  }

  @override
  Future<dynamic> delete(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    return _request(
      () => dio.delete(
        path,
        data: body,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      ),
    );
  }

  Future<dynamic> _request(Future<Response<dynamic>> Function() send) async {
    try {
      final response = await send();
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Never _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      throw NetworkException();
    }

    final status = e.response?.statusCode;
    final data = e.response?.data;

    String? errorCode;
    String message = e.message ?? 'An error occurred.';
    if (data is Map<String, dynamic>) {
      errorCode = data['error'] as String?;
      message = (data['message'] as String?) ?? message;
    }

    if (status == 401) {
      throw UnauthenticatedException(message);
    }
    if (status == 409) {
      throw ConflictException(errorCode: errorCode, message: message);
    }
    if (status != null && status >= 500) {
      throw ServerException(message);
    }
    throw ApiException(
      statusCode: status ?? 0,
      errorCode: errorCode,
      message: message,
    );
  }
}
