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
