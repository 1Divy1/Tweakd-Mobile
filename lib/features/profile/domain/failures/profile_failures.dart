import '../../../../core/error/base_failures.dart';

class UsernameTakenFailure extends Failure {
  const UsernameTakenFailure([
    String message = 'This username is already taken.',
  ]) : super(message: message);
}

class UnauthenticatedFailure extends Failure {
  const UnauthenticatedFailure([
    String message = 'You are not logged in. Please authenticate first.',
  ]) : super(message: message);
}

class ProfileNotFoundFailure extends Failure {
  const ProfileNotFoundFailure([
    String message = 'This user could not be found.',
  ]) : super(message: message);
}

class InvalidUsernameFailure extends Failure {
  const InvalidUsernameFailure([
    String message =
        'Username can only contain lowercase letters, numbers, dots and underscores.',
  ]) : super(message: message);
}

/// The backend rejected an edit-profile payload (name/bio over the length
/// limits, or an invalid avatar key) with a 400.
class ProfileUpdateValidationFailure extends Failure {
  const ProfileUpdateValidationFailure([
    String message = 'Please check your name and bio and try again.',
  ]) : super(message: message);
}

/// The 3-step avatar pipeline failed (compression, presigned PUT to R2, or the
/// commit call) for a reason other than a validation error.
class AvatarUploadFailure extends Failure {
  const AvatarUploadFailure([
    String message = 'We could not update your photo. Please try again.',
  ]) : super(message: message);
}

/// `PATCH /profile/me/language` was rejected (unknown language code) or
/// otherwise failed.
class LanguageUpdateFailure extends Failure {
  const LanguageUpdateFailure([
    String message = 'We could not update your language. Please try again.',
  ]) : super(message: message);
}
