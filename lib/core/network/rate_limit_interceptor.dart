import 'package:dio/dio.dart';

import '../error/base_exceptions.dart';
import 'rate_limit_notifier.dart';

/// Reports every `429` a [Dio] instance receives to the app-wide
/// [RateLimitNotifier], then lets the error continue down the chain untouched.
///
/// Attached to every Dio that talks to the backend: the shared one behind
/// `AbstractHTTP` and the storage data sources that own their own instance.
/// It never retries — a rate-limited request retried immediately would only
/// be refused again.
class RateLimitInterceptor extends Interceptor {
  final RateLimitNotifier notifier;

  RateLimitInterceptor(this.notifier);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    if (response?.statusCode == 429) {
      notifier.report(
        retryAfter: retryAfterOf(response!),
        limit: rateLimitNameOf(response),
      );
    }
    handler.next(err);
  }
}

/// Builds the typed exception for a `429` response. Shared by `DioHttpClient`
/// and the storage data sources so they read the response the same way.
TooManyRequestsException tooManyRequestsFrom(Response<dynamic>? response) {
  final data = response?.data;
  return TooManyRequestsException(
    retryAfter: response == null ? null : retryAfterOf(response),
    limit: response == null ? null : rateLimitNameOf(response),
    errorCode: data is Map<String, dynamic> ? data['error'] as String? : null,
    message: data is Map<String, dynamic>
        ? (data['message'] as String?) ?? 'Too many requests.'
        : 'Too many requests.',
  );
}

/// The wait the backend asked for: the `Retry-After` header (whole seconds),
/// else the body's `details.retry_after_seconds`, else null.
///
/// The HTTP-date form of `Retry-After` is not handled; the backend never sends
/// it and falling back to the body covers the gap.
Duration? retryAfterOf(Response<dynamic> response) {
  final header = int.tryParse(
    response.headers.value('retry-after')?.trim() ?? '',
  );
  if (header != null && header > 0) return Duration(seconds: header);

  final seconds = _details(response)?['retry_after_seconds'];
  if (seconds is num && seconds > 0) {
    return Duration(seconds: seconds.ceil());
  }
  return null;
}

/// The backend limit name from `details.limit`, or null.
String? rateLimitNameOf(Response<dynamic> response) =>
    _details(response)?['limit'] as String?;

Map<String, dynamic>? _details(Response<dynamic> response) {
  final data = response.data;
  if (data is! Map<String, dynamic>) return null;
  final details = data['details'];
  return details is Map<String, dynamic> ? details : null;
}
