import 'dart:math' as math;

import 'package:equatable/equatable.dart';

/// A WGS-84 coordinate.
///
/// Exists as a named type purely so latitude and longitude can't be swapped by
/// accident — the backend speaks `lat`/`lng`, GeoJSON and Mapbox want
/// `[lng, lat]`, and getting that backwards drops every pin in the Atlantic.
/// Conversion to Mapbox's `Position` happens in the presentation layer; the
/// domain never imports `mapbox_maps_flutter`.
class GeoPosition extends Equatable {
  final double lat;
  final double lng;

  const GeoPosition({required this.lat, required this.lng});

  /// Great-circle distance in kilometres. Used to decide whether the camera has
  /// moved far enough from the last fetch to justify another request.
  double distanceKmTo(GeoPosition other) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(other.lat - lat);
    final dLng = _toRadians(other.lng - lng);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat)) *
            math.cos(_toRadians(other.lat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180.0;

  @override
  List<Object?> get props => [lat, lng];
}
