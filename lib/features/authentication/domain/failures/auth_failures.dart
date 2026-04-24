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
