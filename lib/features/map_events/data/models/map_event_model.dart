import 'package:tweakd/features/map/domain/entities/geo_position.dart';

import '../../domain/entities/map_event.dart';
import '../../domain/entities/map_event_enums.dart';
import 'map_event_json.dart';

/// `GET /map-events/{id}` — and the body of nearly every write in the module,
/// which is why so many repository methods return the same entity.
class MapEventModel {
  final String id;
  final String title;
  final String description;
  final String categoryId;
  final String categoryLabel;
  final String locationName;
  final double lat;
  final double lng;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String? coverImageUrl;
  final String? status;
  final String? approvalStatus;
  final String? rejectionReason;
  final bool requiresParticipantApproval;
  final int attendeesCount;
  final int attendingCarsCount;
  final int? maxParticipantCapacity;
  final List<MapEventRuleModel> rules;
  final List<MapEventOrganizerModel> organizers;
  final CarMeetDetailModel? carMeet;
  final MapEventViewerModel? viewer;
  final DateTime createdAt;

  const MapEventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.categoryLabel,
    required this.locationName,
    required this.lat,
    required this.lng,
    required this.startsAt,
    required this.endsAt,
    required this.coverImageUrl,
    required this.status,
    required this.approvalStatus,
    required this.rejectionReason,
    required this.requiresParticipantApproval,
    required this.attendeesCount,
    required this.attendingCarsCount,
    required this.maxParticipantCapacity,
    required this.rules,
    required this.organizers,
    required this.carMeet,
    required this.viewer,
    required this.createdAt,
  });

  factory MapEventModel.fromJson(Map<String, dynamic> json) {
    return MapEventModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      categoryId: json['category_id'] as String? ?? '',
      categoryLabel: json['category_label'] as String? ?? '',
      locationName: json['location_name'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
      startsAt: parseInstant(json['starts_at']),
      endsAt: parseNullableInstant(json['ends_at']),
      coverImageUrl: parseNullableString(json['cover_image_url']),
      status: json['status'] as String?,
      approvalStatus: json['approval_status'] as String?,
      rejectionReason: parseNullableString(json['rejection_reason']),
      requiresParticipantApproval:
          json['requires_participant_approval'] as bool? ?? false,
      attendeesCount: (json['attendees_count'] as num?)?.toInt() ?? 0,
      attendingCarsCount: (json['attending_cars_count'] as num?)?.toInt() ?? 0,
      maxParticipantCapacity:
          (json['max_participant_capacity'] as num?)?.toInt(),
      rules: [
        for (final r in (json['rules'] as List<dynamic>? ?? const []))
          MapEventRuleModel.fromJson(r as Map<String, dynamic>),
      ],
      organizers: [
        for (final o in (json['organizers'] as List<dynamic>? ?? const []))
          MapEventOrganizerModel.fromJson(o as Map<String, dynamic>),
      ],
      carMeet: json['car_meet'] == null
          ? null
          : CarMeetDetailModel.fromJson(json['car_meet'] as Map<String, dynamic>),
      viewer: json['viewer'] == null
          ? null
          : MapEventViewerModel.fromJson(json['viewer'] as Map<String, dynamic>),
      createdAt: parseInstant(json['created_at']),
    );
  }

  MapEventEntity toEntity() {
    return MapEventEntity(
      id: id,
      title: title,
      description: description,
      categoryId: categoryId,
      categoryLabel: categoryLabel,
      locationName: locationName,
      position: GeoPosition(lat: lat, lng: lng),
      startsAt: startsAt,
      endsAt: endsAt,
      coverImageUrl: coverImageUrl,
      status: MapEventStatus.fromApi(status),
      approvalStatus: MapEventApproval.fromApi(approvalStatus),
      rejectionReason: rejectionReason,
      requiresParticipantApproval: requiresParticipantApproval,
      attendeesCount: attendeesCount,
      attendingCarsCount: attendingCarsCount,
      maxParticipantCapacity: maxParticipantCapacity,
      rules: [for (final r in rules) r.toEntity()],
      organizers: [for (final o in organizers) o.toEntity()],
      carMeet: carMeet?.toEntity(),
      // A payload without a viewer object means "no permissions at all", which
      // is the safe default anyway.
      viewer: viewer?.toEntity() ?? const MapEventViewerEntity(),
      createdAt: createdAt,
    );
  }
}

class MapEventRuleModel {
  final String id;
  final String rule;
  final int sortOrder;

  const MapEventRuleModel({
    required this.id,
    required this.rule,
    required this.sortOrder,
  });

  factory MapEventRuleModel.fromJson(Map<String, dynamic> json) {
    return MapEventRuleModel(
      id: json['id'] as String? ?? '',
      rule: json['rule'] as String? ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  MapEventRuleEntity toEntity() =>
      MapEventRuleEntity(id: id, rule: rule, sortOrder: sortOrder);
}

class MapEventOrganizerModel {
  final String id;
  final String? type;
  final String? role;
  final String referenceId;
  final String name;

  /// Individuals only — always null for a business organizer.
  final String? username;

  final String? imageUrl;

  const MapEventOrganizerModel({
    required this.id,
    required this.type,
    required this.role,
    required this.referenceId,
    required this.name,
    required this.username,
    required this.imageUrl,
  });

  factory MapEventOrganizerModel.fromJson(Map<String, dynamic> json) {
    return MapEventOrganizerModel(
      id: json['id'] as String? ?? '',
      type: json['type'] as String?,
      role: json['role'] as String?,
      referenceId: json['reference_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      username: parseNullableString(json['username']),
      imageUrl: parseNullableString(json['image_url']),
    );
  }

  MapEventOrganizerEntity toEntity() {
    return MapEventOrganizerEntity(
      id: id,
      type: MapEventOrganizerType.fromApi(type),
      role: MapEventOrganizerRole.fromApi(role),
      referenceId: referenceId,
      name: name,
      username: username,
      imageUrl: imageUrl,
    );
  }
}

class CarMeetDetailModel {
  final DateTime registrationDeadline;

  const CarMeetDetailModel({required this.registrationDeadline});

  factory CarMeetDetailModel.fromJson(Map<String, dynamic> json) {
    return CarMeetDetailModel(
      registrationDeadline: parseInstant(json['registration_deadline']),
    );
  }

  CarMeetDetailEntity toEntity() =>
      CarMeetDetailEntity(registrationDeadline: registrationDeadline);
}

class MapEventViewerModel {
  final bool isCreator;
  final bool isOrganizer;
  final bool canEdit;
  final String? attendanceStatus;
  final bool canRsvp;
  final bool canRegisterCars;
  final List<String> myRegisteredCarIds;

  const MapEventViewerModel({
    required this.isCreator,
    required this.isOrganizer,
    required this.canEdit,
    required this.attendanceStatus,
    required this.canRsvp,
    required this.canRegisterCars,
    required this.myRegisteredCarIds,
  });

  factory MapEventViewerModel.fromJson(Map<String, dynamic> json) {
    return MapEventViewerModel(
      isCreator: json['is_creator'] as bool? ?? false,
      isOrganizer: json['is_organizer'] as bool? ?? false,
      canEdit: json['can_edit'] as bool? ?? false,
      attendanceStatus: json['attendance_status'] as String?,
      canRsvp: json['can_rsvp'] as bool? ?? false,
      canRegisterCars: json['can_register_cars'] as bool? ?? false,
      myRegisteredCarIds: [
        for (final id
            in (json['my_registered_car_ids'] as List<dynamic>? ?? const []))
          id as String,
      ],
    );
  }

  MapEventViewerEntity toEntity() {
    return MapEventViewerEntity(
      isCreator: isCreator,
      isOrganizer: isOrganizer,
      canEdit: canEdit,
      attendanceStatus: MapEventAttendance.fromApi(attendanceStatus),
      canRsvp: canRsvp,
      canRegisterCars: canRegisterCars,
      myRegisteredCarIds: myRegisteredCarIds,
    );
  }
}
