/// The device can't (or won't) tell us where it is: location services off,
/// permission denied or denied-forever, or the fix timed out.
///
/// Geolocator's own exceptions are caught in the data source and re-thrown as
/// this, so nothing package-specific reaches the repository.
class LocationUnavailableException implements Exception {
  final String message;
  LocationUnavailableException([this.message = 'Location unavailable.']);
}
