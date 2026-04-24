import '../error/base_failures.dart';

class CoreErrorMapper {
  static String getMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'It looks like you are not connected to the internet. Please check your connection and try again.';
    }
    if (failure is ServerFailure) {
      return 'Oops! An error occurred on the server. Please try again.';
    }
    if (failure is UnknownFailure) {
      return 'Something went wrong. Please try again.';
    }
    
    // Default case for unknown failures
    return failure.message;
  }
}