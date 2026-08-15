import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

import '../exceptions/map_exceptions.dart';

/// Reads the device's position for the map's "near me" query.
///
/// Foreground-only and one-shot: the map centres on the user once, then follows
/// the camera. Nothing here subscribes to a position stream, which is why the
/// app asks for `whenInUse` and never background location.
@lazySingleton
class DeviceLocationDataSource {
  /// A coarse fix is plenty — the query radius is 25 km, so metre-level
  /// accuracy would only cost battery and time.
  static const _settings = LocationSettings(
    accuracy: LocationAccuracy.low,
    timeLimit: Duration(seconds: 8),
  );

  /// Current position, prompting for permission if it hasn't been decided.
  ///
  /// Throws [LocationUnavailableException] for every "no" — services disabled,
  /// permission denied or permanently denied, timeout, platform error. The
  /// caller treats them all the same way (fall back to the default centre), so
  /// they aren't worth distinguishing.
  Future<({double lat, double lng})> getCurrentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw LocationUnavailableException('Location services are disabled.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw LocationUnavailableException('Location permission denied.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: _settings,
      );
      return (lat: position.latitude, lng: position.longitude);
    } on LocationUnavailableException {
      rethrow;
    } catch (e) {
      // A cold GPS can time out; a last-known fix is far better than nothing
      // and is already good enough for a 25 km radius.
      final last = await _lastKnownOrNull();
      if (last != null) return last;
      throw LocationUnavailableException('Could not determine location: $e');
    }
  }

  Future<({double lat, double lng})?> _lastKnownOrNull() async {
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last == null) return null;
      return (lat: last.latitude, lng: last.longitude);
    } catch (_) {
      return null;
    }
  }
}
