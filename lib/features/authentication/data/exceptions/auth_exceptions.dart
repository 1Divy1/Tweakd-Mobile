class DuplicateDataException implements Exception {}

class NoActiveSessionException implements Exception {
  final String message;
  NoActiveSessionException([
    this.message = 'No active session found. Please log in.',
  ]);
}