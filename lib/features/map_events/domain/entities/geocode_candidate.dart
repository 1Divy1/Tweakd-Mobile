import 'package:equatable/equatable.dart';

/// What kind of thing a geocode hit is. Mapbox's list is open-ended, so
/// anything unrecognised falls through to [other] rather than throwing.
enum GeocodeFeatureType {
  address,
  street,
  place,
  postcode,
  region,
  country,
  other;

  static GeocodeFeatureType fromApi(String? value) => switch (value) {
        'address' => GeocodeFeatureType.address,
        'street' => GeocodeFeatureType.street,
        'place' => GeocodeFeatureType.place,
        'postcode' => GeocodeFeatureType.postcode,
        'region' => GeocodeFeatureType.region,
        'country' => GeocodeFeatureType.country,
        _ => GeocodeFeatureType.other,
      };
}

/// How precisely an address-level hit was resolved. Null on the wire for
/// anything coarser than an address, which is why [none] exists.
///
/// The order matters to the user's choice: [rooftop] and [parcel] point at the
/// building itself, [point] and [intersection] at something nearby, while
/// [interpolated] and [approximate] are a guess along a street — the last two
/// are exactly the cases where dropping the pin by hand is doing real work.
enum GeocodeAccuracy {
  rooftop,
  parcel,
  point,
  interpolated,
  approximate,
  intersection,
  none;

  static GeocodeAccuracy fromApi(String? value) => switch (value) {
        'rooftop' => GeocodeAccuracy.rooftop,
        'parcel' => GeocodeAccuracy.parcel,
        'point' => GeocodeAccuracy.point,
        'interpolated' => GeocodeAccuracy.interpolated,
        'approximate' => GeocodeAccuracy.approximate,
        'intersection' => GeocodeAccuracy.intersection,
        _ => GeocodeAccuracy.none,
      };

  /// Whether the coordinate is precise enough that the suggested camera
  /// position is likely already on the right building.
  bool get isExact =>
      this == GeocodeAccuracy.rooftop || this == GeocodeAccuracy.parcel;
}

/// One hit from `GET /map-events/geocode`.
///
/// **These coordinates are never persisted.** They exist only to point the
/// camera at roughly the right place; the coordinate the event is created with
/// is the one the user taps onto the map themselves. Keeping Mapbox's numbers
/// out of the database is what keeps the app clear of the permanent-geocoding
/// licence — see `MAP_EVENTS_NOTES.md` §1.7.
class GeocodeCandidateEntity extends Equatable {
  final double lat;
  final double lng;

  /// Mapbox's formatted display string. Shown in the results list so the user
  /// can tell candidates apart — but never written to the event, whose
  /// `location_name` is composed from the address fields the user typed.
  final String placeName;

  final GeocodeFeatureType featureType;
  final GeocodeAccuracy accuracy;

  const GeocodeCandidateEntity({
    required this.lat,
    required this.lng,
    required this.placeName,
    required this.featureType,
    required this.accuracy,
  });

  @override
  List<Object?> get props => [lat, lng, placeName, featureType, accuracy];
}
