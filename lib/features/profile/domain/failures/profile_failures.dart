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
