class ServerException implements Exception {
  final String message;
  
  // Optional argument with a default message
  ServerException([this.message = 'A server error occurred.']);
}

class CacheException implements Exception {}