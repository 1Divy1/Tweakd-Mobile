import '../../../../core/error/base_failures.dart';
import '../../../../core/utils/core_error_mapper.dart';
import '../../../profile/domain/failures/profile_failures.dart';

/// Maps onboarding submit failures to user-facing copy. The submit reuses the
/// profile failures (it hits `POST /profile/onboarding`), so username-specific
/// cases are handled here before falling through to the generic mapper.
class OnboardingErrorMapper {
  static String getMessage(Failure failure) {
    if (failure is UsernameTakenFailure) {
      return 'That handle is already taken. Try another one.';
    }
    if (failure is UnauthenticatedFailure) {
      return 'Your session is not active. Please log in again.';
    }
    if (failure is InvalidUsernameFailure) {
      return failure.message;
    }
    return CoreErrorMapper.getMessage(failure);
  }
}
