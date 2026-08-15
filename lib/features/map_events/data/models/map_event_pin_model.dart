import 'package:car_social_media_app/features/map/domain/entities/geo_position.dart';

import '../../domain/entities/map_event_enums.dart';
import '../../domain/entities/map_event_pin.dart';
import 'map_event_json.dart';

/// One item of `GET /map-events/nearby`.
///
/// Note the absence of `distance_km` — the backend removed it, and the app
/// computes any displayed distance itself from [lat]/[lng].
class MapEventPinModel {
  final String id;
  final String title;
  final String categoryId;
  final String categoryLabel;
  final double lat;
  final double lng;
  final String locationName;
  final String? coverImageUrl;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String? status;
  final int attendeesCount;
  final int attendingCarsCount;
  final int? maxParticipantCapacity;

  const MapEventPinModel({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.categoryLabel,
    required this.lat,
    required this.lng,
    required this.locationName,
    required this.coverImageUrl,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.attendeesCount,
    required this.attendingCarsCount,
    required this.maxParticipantCapacity,
  });

  factory MapEventPinModel.fromJson(Map<String, dynamic> json) {
    return MapEventPinModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      categoryId: json['category_id'] as String? ?? '',
      categoryLabel: json['category_label'] as String? ?? '',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      locationName: json['location_name'] as String? ?? '',
      coverImageUrl: parseNullableString(json['cover_image_url']),
      startsAt: parseInstant(json['starts_at']),
      endsAt: parseNullableInstant(json['ends_at']),
      status: json['status'] as String?,
      attendeesCount: (json['attendees_count'] as num?)?.toInt() ?? 0,
      attendingCarsCount: (json['attending_cars_count'] as num?)?.toInt() ?? 0,
      maxParticipantCapacity:
          (json['max_participant_capacity'] as num?)?.toInt(),
    );
  }

  MapEventPinEntity toEntity() {
    return MapEventPinEntity(
      id: id,
      title: title,
      categoryId: categoryId,
      categoryLabel: categoryLabel,
      position: GeoPosition(lat: lat, lng: lng),
      locationName: locationName,
      coverImageUrl: coverImageUrl,
      startsAt: startsAt,
      endsAt: endsAt,
      status: MapEventStatus.fromApi(status),
      attendeesCount: attendeesCount,
      attendingCarsCount: attendingCarsCount,
      maxParticipantCapacity: maxParticipantCapacity,
    );
  }
}
