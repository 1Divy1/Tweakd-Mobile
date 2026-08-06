import 'package:equatable/equatable.dart';

import 'geo_position.dart';

/// A business as it appears *on the map* — the lightweight shape returned by
/// `GET /businesses/nearby`. Tapping one fetches the full
/// [BusinessDetailEntity]; this carries only what a pin needs to draw.
class BusinessPinEntity extends Equatable {
  final String id;
  final String name;

  /// Stable machine id (`car_wash`, `tire_shop`, …) — safe to switch on.
  final String typeId;

  /// Human-readable label for [typeId], already localized by the backend.
  final String typeLabel;

  final GeoPosition position;

  /// Absolute URL to the business logo, drawn inside the circular marker.
  /// May be empty when a business hasn't uploaded one.
  final String logoUrl;

  final double averageRating;
  final int reviewCount;
  final bool isOpenNow;

  /// Distance from the query centre, as computed by the backend.
  final double distanceKm;

  const BusinessPinEntity({
    required this.id,
    required this.name,
    required this.typeId,
    required this.typeLabel,
    required this.position,
    required this.logoUrl,
    required this.averageRating,
    required this.reviewCount,
    required this.isOpenNow,
    required this.distanceKm,
  });

  bool get hasRating => reviewCount > 0;

  @override
  List<Object?> get props => [
        id,
        name,
        typeId,
        typeLabel,
        position,
        logoUrl,
        averageRating,
        reviewCount,
        isOpenNow,
        distanceKm,
      ];
}
