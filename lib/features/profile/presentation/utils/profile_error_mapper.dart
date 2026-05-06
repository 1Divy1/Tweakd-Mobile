import '../../../../core/error/base_failures.dart';
import '../../../../core/utils/core_error_mapper.dart';
import '../../domain/failures/profile_failures.dart';

class ProfileErrorMapper {
  static String getMessage(Failure failure) {
    if (failure is UsernameTakenFailure) {
      return 'The username is already taken. Please choose a different one.';
    }
    if (failure is UnauthenticatedFailure) {
      return 'Your session is not active. Please log in again.';
    }
    if (failure is ProfileNotFoundFailure) {
      return failure.message;
    }
    if (failure is InvalidUsernameFailure) {
      return failure.message;
    }

    return CoreErrorMapper.getMessage(failure);
  }
}
