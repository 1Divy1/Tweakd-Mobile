import 'package:car_social_media_app/features/garage/data/models/car_summary_model.dart';
import 'package:car_social_media_app/features/map/domain/entities/geo_position.dart';

import '../../domain/entities/geocode_candidate.dart';
import '../../domain/entities/map_event_attendee.dart';
import '../../domain/entities/map_event_category.dart';
import '../../domain/entities/map_event_enums.dart';
import '../../domain/entities/map_event_page.dart';
import '../../domain/entities/map_event_participant.dart';
import '../../domain/entities/map_event_summary.dart';
import '../../domain/entities/map_event_withdrawal_request.dart';
import '../../domain/entities/organizer_candidate.dart';
import 'map_event_json.dart';

/// A cursor page as the module sends it: `{ items: [...], next_cursor }`.
///
/// Generic over the item model so every paginated endpoint reuses it; the
/// caller supplies the per-item parser and the entity mapper.
class MapEventPageModel<T> {
  final List<T> items;
  final String? nextCursor;

  const MapEventPageModel({required this.items, required this.nextCursor});

  factory MapEventPageModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parseItem,
  ) {
    return MapEventPageModel(
      items: [
        for (final item in (json['items'] as List<dynamic>? ?? const []))
          parseItem(item as Map<String, dynamic>),
      ],
      nextCursor: parseNullableString(json['next_cursor']),
    );
  }

  MapEventPageEntity<E> toEntity<E>(E Function(T) map) {
    return MapEventPageEntity<E>(
      items: [for (final i in items) map(i)],
      nextCursor: nextCursor,
    );
  }
}

// ── Categories ─────────────────────────────────────────────────────────────

class MapEventCategoryModel {
  final String id;
  final String label;

  const MapEventCategoryModel({required this.id, required this.label});

  factory MapEventCategoryModel.fromJson(Map<String, dynamic> json) {
    return MapEventCategoryModel(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );
  }

  MapEventCategoryEntity toEntity() =>
      MapEventCategoryEntity(id: id, label: label);
}

// ── My events ──────────────────────────────────────────────────────────────

class MapEventSummaryModel {
  final String id;
  final String title;
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
  final int attendeesCount;
  final int attendingCarsCount;
  final int? maxParticipantCapacity;
  final String creatorId;
  final String creatorUsername;
  final String? creatorAvatarUrl;
  final DateTime createdAt;

  const MapEventSummaryModel({
    required this.id,
    required this.title,
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
    required this.attendeesCount,
    required this.attendingCarsCount,
    required this.maxParticipantCapacity,
    required this.creatorId,
    required this.creatorUsername,
    required this.creatorAvatarUrl,
    required this.createdAt,
  });

  factory MapEventSummaryModel.fromJson(Map<String, dynamic> json) {
    final creator = json['creator'] as Map<String, dynamic>? ?? const {};
    return MapEventSummaryModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
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
      attendeesCount: (json['attendees_count'] as num?)?.toInt() ?? 0,
      attendingCarsCount: (json['attending_cars_count'] as num?)?.toInt() ?? 0,
      maxParticipantCapacity:
          (json['max_participant_capacity'] as num?)?.toInt(),
      creatorId: creator['id'] as String? ?? '',
      creatorUsername: creator['username'] as String? ?? '',
      creatorAvatarUrl: parseNullableString(creator['avatar_url']),
      createdAt: parseInstant(json['created_at']),
    );
  }

  MapEventSummaryEntity toEntity() {
    return MapEventSummaryEntity(
      id: id,
      title: title,
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
      attendeesCount: attendeesCount,
      attendingCarsCount: attendingCarsCount,
      maxParticipantCapacity: maxParticipantCapacity,
      creator: MapEventCreatorEntity(
        id: creatorId,
        username: creatorUsername,
        avatarUrl: creatorAvatarUrl,
      ),
      createdAt: createdAt,
    );
  }
}

// ── Attendees ──────────────────────────────────────────────────────────────

class MapEventAttendeeModel {
  final String id;
  final String username;
  final String? name;
  final String? avatarUrl;
  final String? status;

  const MapEventAttendeeModel({
    required this.id,
    required this.username,
    required this.name,
    required this.avatarUrl,
    required this.status,
  });

  factory MapEventAttendeeModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>? ?? const {};
    return MapEventAttendeeModel(
      id: profile['id'] as String? ?? '',
      username: profile['username'] as String? ?? '',
      name: parseNullableString(profile['name']),
      avatarUrl: parseNullableString(profile['avatar_url']),
      status: json['status'] as String?,
    );
  }

  MapEventAttendeeEntity toEntity() {
    return MapEventAttendeeEntity(
      id: id,
      username: username,
      name: name,
      avatarUrl: avatarUrl,
      // The list endpoint is queried per status, so an unparsable one is
      // effectively impossible; `interested` is the softer default.
      status: MapEventAttendance.fromApi(status) ?? MapEventAttendance.interested,
    );
  }
}

// ── Entry list ─────────────────────────────────────────────────────────────

class MapEventParticipantModel {
  final CarSummaryModel car;
  final String? status;
  final DateTime registeredAt;
  final String? rejectionReason;

  const MapEventParticipantModel({
    required this.car,
    required this.status,
    required this.registeredAt,
    required this.rejectionReason,
  });

  factory MapEventParticipantModel.fromJson(Map<String, dynamic> json) {
    return MapEventParticipantModel(
      // Same `CarSummaryDto` the garage module already models — reused rather
      // than re-declared, so a change to the car shape lands in one place.
      car: CarSummaryModel.fromJson(json['car'] as Map<String, dynamic>),
      status: json['status'] as String?,
      registeredAt: parseInstant(json['registered_at']),
      // Null unless the row is `rejected`.
      rejectionReason: parseNullableString(json['rejection_reason']),
    );
  }

  MapEventParticipantEntity toEntity() {
    return MapEventParticipantEntity(
      car: car.toEntity(),
      status: MapEventParticipation.fromApi(status),
      registeredAt: registeredAt,
      rejectionReason: rejectionReason,
    );
  }
}

// ── Withdrawals ────────────────────────────────────────────────────────────

class MapEventWithdrawalRequestModel {
  final String ownerId;
  final String ownerUsername;
  final String? ownerAvatarUrl;
  final List<CarSummaryModel> cars;
  final String? note;

  const MapEventWithdrawalRequestModel({
    required this.ownerId,
    required this.ownerUsername,
    required this.ownerAvatarUrl,
    required this.cars,
    required this.note,
  });

  factory MapEventWithdrawalRequestModel.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] as Map<String, dynamic>? ?? const {};
    return MapEventWithdrawalRequestModel(
      ownerId: owner['id'] as String? ?? '',
      ownerUsername: owner['username'] as String? ?? '',
      ownerAvatarUrl: parseNullableString(owner['avatar_url']),
      cars: [
        for (final c in (json['cars'] as List<dynamic>? ?? const []))
          CarSummaryModel.fromJson(c as Map<String, dynamic>),
      ],
      note: parseNullableString(json['note']),
    );
  }

  MapEventWithdrawalRequestEntity toEntity() {
    return MapEventWithdrawalRequestEntity(
      ownerId: ownerId,
      ownerUsername: ownerUsername,
      ownerAvatarUrl: ownerAvatarUrl,
      cars: [for (final c in cars) c.toEntity()],
      note: note,
    );
  }
}

// ── Organizer search ───────────────────────────────────────────────────────

class OrganizerCandidateModel {
  final String? type;
  final String referenceId;
  final String name;
  final String? username;
  final String? imageUrl;

  const OrganizerCandidateModel({
    required this.type,
    required this.referenceId,
    required this.name,
    required this.username,
    required this.imageUrl,
  });

  factory OrganizerCandidateModel.fromJson(Map<String, dynamic> json) {
    return OrganizerCandidateModel(
      type: json['type'] as String?,
      referenceId: json['reference_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      // Null on a business hit.
      username: parseNullableString(json['username']),
      imageUrl: parseNullableString(json['image_url']),
    );
  }

  OrganizerCandidateEntity toEntity() {
    return OrganizerCandidateEntity(
      type: MapEventOrganizerType.fromApi(type),
      referenceId: referenceId,
      name: name,
      username: username,
      imageUrl: imageUrl,
    );
  }
}

// ── Location search ──────────────────────────────────────────────────────

/// A hit from `GET /map-events/geocode`. Up to five come back, best first.
class GeocodeCandidateModel {
  final double lat;
  final double lng;
  final String placeName;
  final String? featureType;

  /// Null on the wire for anything coarser than an address.
  final String? accuracy;

  const GeocodeCandidateModel({
    required this.lat,
    required this.lng,
    required this.placeName,
    required this.featureType,
    required this.accuracy,
  });

  factory GeocodeCandidateModel.fromJson(Map<String, dynamic> json) {
    return GeocodeCandidateModel(
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
      placeName: json['place_name'] as String? ?? '',
      featureType: parseNullableString(json['feature_type']),
      accuracy: parseNullableString(json['accuracy']),
    );
  }

  GeocodeCandidateEntity toEntity() {
    return GeocodeCandidateEntity(
      lat: lat,
      lng: lng,
      placeName: placeName,
      featureType: GeocodeFeatureType.fromApi(featureType),
      accuracy: GeocodeAccuracy.fromApi(accuracy),
    );
  }
}

// ── Storage ────────────────────────────────────────────────────────────────

/// `GET /api/storage/events/{event_id}/cover` — the presigned slot for a cover
/// image. [key] is what `PATCH /map-events/{id}/cover` wants back.
class MapEventCoverUploadModel {
  final String key;
  final String uploadUrl;

  const MapEventCoverUploadModel({required this.key, required this.uploadUrl});

  factory MapEventCoverUploadModel.fromJson(Map<String, dynamic> json) {
    return MapEventCoverUploadModel(
      key: json['key'] as String? ?? '',
      uploadUrl: json['upload_url'] as String? ?? '',
    );
  }
}
