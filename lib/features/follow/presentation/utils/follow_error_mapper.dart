import '../../../../core/error/base_failures.dart';
import '../../../../core/utils/core_error_mapper.dart';
import '../../domain/failures/follow_failures.dart';

class FollowErrorMapper {
  static String getMessage(Failure failure) {
    if (failure is CannotFollowSelfFailure) return failure.message;
    if (failure is PrivateProfileFailure) return failure.message;
    if (failure is TargetUserNotFoundFailure) return failure.message;
    if (failure is FollowRequestNotFoundFailure) return failure.message;
    if (failure is UnauthenticatedFollowFailure) {
      return 'Your session is not active. Please log in again.';
    }
    return CoreErrorMapper.getMessage(failure);
  }
}
