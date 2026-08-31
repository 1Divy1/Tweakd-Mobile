import 'package:tweakd/core/error/base_failures.dart';

class CarNotFoundFailure extends Failure {
  const CarNotFoundFailure() : super(message: 'Car not found.');
}

class GarageNotFoundFailure extends Failure {
  const GarageNotFoundFailure() : super(message: 'Garage not found.');
}

class PrivateGarageFailure extends Failure {
  const PrivateGarageFailure() : super(message: 'This garage is private.');
}

class NotCarOwnerFailure extends Failure {
  const NotCarOwnerFailure() : super(message: 'You do not own this car.');
}

class InvalidReferenceFailure extends Failure {
  const InvalidReferenceFailure(String message) : super(message: message);
}
