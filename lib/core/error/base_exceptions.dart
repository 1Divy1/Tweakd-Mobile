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
  ConflictException({this.errorCode, this.message = 'Conflict.'});
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
