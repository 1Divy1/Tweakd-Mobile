import '../../domain/entities/business_pin_entity.dart';
import '../../domain/entities/geo_position.dart';

/// One item of `GET /businesses/nearby`. snake_case on the wire, as everywhere.
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
  final double distanceKm;

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
    required this.distanceKm,
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
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0,
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
      distanceKm: distanceKm,
    );
  }
}
