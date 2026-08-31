import 'package:tweakd/features/map/domain/entities/geo_position.dart';
import 'package:equatable/equatable.dart';

import 'map_event_enums.dart';

/// The user behind an event, as `GET /map-events/mine` sends them.
class MapEventCreatorEntity extends Equatable {
  final String id;
  final String username;
  final String? avatarUrl;

  const MapEventCreatorEntity({
    required this.id,
    required this.username,
    required this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, username, avatarUrl];
}

/// A row in "My events" (`GET /map-events/mine`).
///
/// Unlike a map pin this carries [approvalStatus] and [rejectionReason] — the
/// whole point of the list is seeing events that haven't reached the map yet.
class MapEventSummaryEntity extends Equatable {
  final String id;
  final String title;
  final String categoryId;
  final String categoryLabel;
  final String locationName;
  final GeoPosition position;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String? coverImageUrl;
  final MapEventStatus status;
  final MapEventApproval approvalStatus;
  final String? rejectionReason;
  final int attendeesCount;
  final int attendingCarsCount;
  final int? maxParticipantCapacity;
  final MapEventCreatorEntity creator;
  final DateTime createdAt;

  const MapEventSummaryEntity({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.categoryLabel,
    required this.locationName,
    required this.position,
    required this.startsAt,
    required this.endsAt,
    required this.coverImageUrl,
    required this.status,
    required this.approvalStatus,
    required this.rejectionReason,
    required this.attendeesCount,
    required this.attendingCarsCount,
    required this.maxParticipantCapacity,
    required this.creator,
    required this.createdAt,
  });

  /// Editing (`PATCH` / `PUT /rules`) is only open while the admins haven't
  /// accepted the event yet.
  bool get isEditable => approvalStatus.isEditable;

  @override
  List<Object?> get props => [
        id,
        title,
        categoryId,
        categoryLabel,
        locationName,
        position,
        startsAt,
        endsAt,
        coverImageUrl,
        status,
        approvalStatus,
        rejectionReason,
        attendeesCount,
        attendingCarsCount,
        maxParticipantCapacity,
        creator,
        createdAt,
      ];
}
