import 'package:car_social_media_app/features/map/domain/entities/geo_position.dart';
import 'package:equatable/equatable.dart';

import 'map_event_enums.dart';

/// An event as it appears *on the map* — the lightweight shape returned by
/// `GET /map-events/nearby`. Tapping one opens the preview popup, which fetches
/// the full [MapEventEntity]; this carries only what a pin and its preview
/// header need.
///
/// There is no `distance_km`: the backend dropped it as a worthless
/// straight-line field, so any distance shown is computed on the client from
/// [position] against the centre the map queried around.
class MapEventPinEntity extends Equatable {
  final String id;
  final String title;

  /// Stable machine id (`car_meet`, …) — safe to switch on.
  final String categoryId;

  /// Human-readable label for [categoryId], already localized by the backend.
  final String categoryLabel;

  final GeoPosition position;

  /// Venue name as typed by the organizer ("Port Hercule — Level 2").
  final String locationName;

  /// Absolute URL of the cover image, drawn inside the circular marker.
  /// Null for events whose organizer never uploaded one.
  final String? coverImageUrl;

  final DateTime startsAt;
  final DateTime? endsAt;

  /// Only `upcoming` and `live` events are ever pinned on the map.
  final MapEventStatus status;

  final int attendeesCount;
  final int attendingCarsCount;

  /// Null means no participant cap.
  final int? maxParticipantCapacity;

  const MapEventPinEntity({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.categoryLabel,
    required this.position,
    required this.locationName,
    required this.coverImageUrl,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.attendeesCount,
    required this.attendingCarsCount,
    required this.maxParticipantCapacity,
  });

  bool get isLive => status == MapEventStatus.live;

  /// True once the entry list is full. The register-car button greys out on
  /// this, on top of the 409 the backend raises for the same reason.
  bool get isAtCapacity {
    final cap = maxParticipantCapacity;
    return cap != null && attendingCarsCount >= cap;
  }

  /// Patches the counts after the viewer acts on the event from its popup, so
  /// the pin and the open card agree without refetching the whole nearby ring.
  MapEventPinEntity copyWith({int? attendeesCount, int? attendingCarsCount}) {
    return MapEventPinEntity(
      id: id,
      title: title,
      categoryId: categoryId,
      categoryLabel: categoryLabel,
      position: position,
      locationName: locationName,
      coverImageUrl: coverImageUrl,
      startsAt: startsAt,
      endsAt: endsAt,
      status: status,
      attendeesCount: attendeesCount ?? this.attendeesCount,
      attendingCarsCount: attendingCarsCount ?? this.attendingCarsCount,
      maxParticipantCapacity: maxParticipantCapacity,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        categoryId,
        categoryLabel,
        position,
        locationName,
        coverImageUrl,
        startsAt,
        endsAt,
        status,
        attendeesCount,
        attendingCarsCount,
        maxParticipantCapacity,
      ];
}
