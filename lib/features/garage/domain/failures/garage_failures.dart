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

/// The code in a share link resolves to nothing: it was never issued, or it
/// was mistyped past what the backend's normalisation can rescue.
class ShareLinkNotFoundFailure extends Failure {
  const ShareLinkNotFoundFailure() : super(message: 'Share link not found.');
}

/// The code is real but no longer serves: paused by its owner, revoked (the
/// car changed hands), or the owner is banned. 410, not 404 — the difference
/// matters to crawlers, not to the copy we show.
class ShareLinkGoneFailure extends Failure {
  const ShareLinkGoneFailure()
      : super(message: 'This build is no longer shared.');
}
