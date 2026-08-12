import '../../domain/entities/business_pin_entity.dart';
import '../../domain/entities/geo_position.dart';

/// One item of `GET /businesses/nearby`. snake_case on the wire, as everywhere.
///
/// No `distance_km`: the backend removed it from this endpoint (and from
/// `/map-events/nearby`) because a straight-line distance is something the
/// client can compute for itself. Anything the UI shows — or sorts by — is
/// derived from [lat]/[lng] against the centre the map queried around.
class BusinessPinModel {
  final String id;
  final String name;
  final String typeId;
  final String typeLabel;
  final double lat;
  final double lng;
  final String logoUrl;
  final double averageRating;
  final int reviewCount;
  final bool isOpenNow;

  const BusinessPinModel({
    required this.id,
    required this.name,
    required this.typeId,
    required this.typeLabel,
    required this.lat,
    required this.lng,
    required this.logoUrl,
    required this.averageRating,
    required this.reviewCount,
    required this.isOpenNow,
  });

  factory BusinessPinModel.fromJson(Map<String, dynamic> json) {
    return BusinessPinModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      typeId: json['type_id'] as String? ?? '',
      typeLabel: json['type_label'] as String? ?? '',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      logoUrl: json['logo_url'] as String? ?? '',
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      isOpenNow: json['is_open_now'] as bool? ?? false,
    );
  }

  BusinessPinEntity toEntity() {
    return BusinessPinEntity(
      id: id,
      name: name,
      typeId: typeId,
      typeLabel: typeLabel,
      position: GeoPosition(lat: lat, lng: lng),
      logoUrl: logoUrl,
      averageRating: averageRating,
      reviewCount: reviewCount,
      isOpenNow: isOpenNow,
    );
  }
}
