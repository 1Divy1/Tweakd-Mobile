import '../../../../core/error/base_failures.dart';

class TargetUserNotFoundFailure extends Failure {
  const TargetUserNotFoundFailure([
    String message = 'This user could not be found.',
  ]) : super(message: message);
}

class CannotFollowSelfFailure extends Failure {
  const CannotFollowSelfFailure([
    String message = 'You cannot follow yourself.',
  ]) : super(message: message);
}

class PrivateProfileFailure extends Failure {
  const PrivateProfileFailure([
    String message = 'This profile is private.',
  ]) : super(message: message);
}

class FollowRequestNotFoundFailure extends Failure {
  const FollowRequestNotFoundFailure([
    String message = 'No pending follow request from this user.',
  ]) : super(message: message);
}

class UnauthenticatedFollowFailure extends Failure {
  const UnauthenticatedFollowFailure([
    String message = 'You are not logged in. Please authenticate first.',
  ]) : super(message: message);
}
