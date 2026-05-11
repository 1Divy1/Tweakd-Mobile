import '../../../../core/error/base_failures.dart';

class UnauthenticatedFailure extends Failure {
  const UnauthenticatedFailure([
    String message = 'You are not logged in. Please authenticate first.',
  ]) : super(message: message);
}
