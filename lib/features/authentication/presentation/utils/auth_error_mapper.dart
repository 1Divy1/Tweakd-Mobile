import '../../../../core/error/base_failures.dart';
import '../../../../core/utils/core_error_mapper.dart';
import '../../domain/failures/auth_failures.dart';

class AuthErrorMapper {
  static String getMessage(Failure failure) {
    if (failure is UsernameTakenFailure) {
      return 'The username is already taken. Please choose a different one.';
    }
    if (failure is UnauthenticatedFailure) {
      return 'Your session is not active. Please log in again.';
    }

    // If it's not an AuthFailure, we can use the CoreErrorMapper to get a generic message
    return CoreErrorMapper.getMessage(failure);
  }
}