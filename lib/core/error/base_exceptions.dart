class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'A server error occurred.']);
}

class NetworkException implements Exception {}

class CacheException implements Exception {}