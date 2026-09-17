class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'A server error occurred.']);
}

class NetworkException implements Exception {}

class CacheException implements Exception {}

class UnauthenticatedException implements Exception {
  final String message;
  UnauthenticatedException([this.message = 'Authentication required.']);
}

class ConflictException implements Exception {
  final String? errorCode;
  final String message;

  /// Structured detail the backend attaches to some conflicts (e.g. a
  /// cooldown's `next_post_allowed_at`), or null.
  final Map<String, dynamic>? details;
  ConflictException({this.errorCode, this.message = 'Conflict.', this.details});
}

class ApiException implements Exception {
  final int statusCode;
  final String? errorCode;
  final String message;
  ApiException({
    required this.statusCode,
    this.errorCode,
    this.message = 'An API error occurred.',
  });
}

class RequestCancelledException implements Exception {}

/// A `429 Too Many Requests` from the backend's rate limiter.
///
/// Extends [ApiException] so every existing `on ApiException` handler keeps
/// catching it exactly as before; the user-facing explanation is shown
/// app-wide by `RateLimitBanner`, not by each feature.
class TooManyRequestsException extends ApiException {
  /// How long the backend asked the caller to wait, or null when the response
  /// carried no usable value.
  final Duration? retryAfter;

  /// The backend limit that refused the request (`details.limit`, e.g.
  /// `comments`), or null.
  final String? limit;

  TooManyRequestsException({
    this.retryAfter,
    this.limit,
    super.errorCode,
    super.message = 'Too many requests.',
  }) : super(statusCode: 429);
}
