import '../../../../core/error/base_failures.dart';

/// The business is gone, suspended, pending or rejected — the backend answers
/// 404 for all of them **by design**, so the UI must not try to tell them apart.
class BusinessNotFoundFailure extends Failure {
  const BusinessNotFoundFailure(String message) : super(message: message);
}

/// The device refused or couldn't produce a fix (permission denied, services
/// off, timeout). Not an error the user sees — the map quietly falls back to
/// its default centre.
class LocationUnavailableFailure extends Failure {
  const LocationUnavailableFailure(String message) : super(message: message);
}
