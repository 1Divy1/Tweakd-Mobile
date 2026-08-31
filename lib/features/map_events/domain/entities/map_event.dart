import 'package:tweakd/features/map/domain/entities/geo_position.dart';
import 'package:equatable/equatable.dart';

import 'map_event_enums.dart';

/// One line of "Notes from the organizer". Ordering is backend-managed and
/// already applied — [sortOrder] is carried for completeness, not for sorting.
class MapEventRuleEntity extends Equatable {
  final String id;
  final String rule;
  final int sortOrder;

  const MapEventRuleEntity({
    required this.id,
    required this.rule,
    required this.sortOrder,
  });

  @override
  List<Object?> get props => [id, rule, sortOrder];
}

/// A person or business running the event.
///
/// [name] is the display name; [username] is the handle, and exists for
/// **individuals only** — a business organizer has no username, so its row
/// shows the name alone until business profiles get a route of their own.
/// [referenceId] is the underlying user or business id, and is what
/// `POST /{id}/organizers` wants; [id] is the organizer row itself, which is
/// what `DELETE /{id}/organizers/{organizer_id}` wants. They are not
/// interchangeable.
class MapEventOrganizerEntity extends Equatable {
  final String id;
  final MapEventOrganizerType type;
  final MapEventOrganizerRole role;
  final String referenceId;
  final String name;
  final String? username;
  final String? imageUrl;

  const MapEventOrganizerEntity({
    required this.id,
    required this.type,
    required this.role,
    required this.referenceId,
    required this.name,
    required this.username,
    required this.imageUrl,
  });

  bool get isBusiness => type == MapEventOrganizerType.business;
  bool get isCreator => role == MapEventOrganizerRole.creator;

  /// Whether the row can navigate: the profile route is `/users/:username`, so
  /// a missing handle means there is nowhere to go.
  bool get hasProfile => (username ?? '').isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        type,
        role,
        referenceId,
        name,
        username,
        imageUrl,
      ];
}

/// Category-specific detail. Only car meets have one today, and it's null for
/// every other category.
class CarMeetDetailEntity extends Equatable {
  /// After this moment no more cars can be registered. Required for car meets.
  final DateTime registrationDeadline;

  const CarMeetDetailEntity({required this.registrationDeadline});

  bool get hasPassed => DateTime.now().isAfter(registrationDeadline);

  @override
  List<Object?> get props => [registrationDeadline];
}

/// What *this* viewer may do with the event, as the backend sees it.
///
/// [myRegisteredCarIds] holds the caller's cars in the event **whatever their
/// status** — pending, accepted, rejected and withdrawn are all in there, with
/// no per-car status alongside. Learning which is which means cross-referencing
/// these ids against `GET /{id}/cars` rows, and the pending/rejected slices of
/// that endpoint are organizer-only (`MAP_EVENTS_NOTES.md` §1.2).
class MapEventViewerEntity extends Equatable {
  final bool isCreator;
  final bool isOrganizer;
  final bool canEdit;
  final MapEventAttendance? attendanceStatus;
  final bool canRsvp;
  final bool canRegisterCars;
  final List<String> myRegisteredCarIds;

  const MapEventViewerEntity({
    this.isCreator = false,
    this.isOrganizer = false,
    this.canEdit = false,
    this.attendanceStatus,
    this.canRsvp = false,
    this.canRegisterCars = false,
    this.myRegisteredCarIds = const [],
  });

  bool get hasCarsRegistered => myRegisteredCarIds.isNotEmpty;

  bool get isAttending => attendanceStatus == MapEventAttendance.attending;
  bool get isInterested => attendanceStatus == MapEventAttendance.interested;

  MapEventViewerEntity copyWith({
    MapEventAttendance? attendanceStatus,
    bool clearAttendance = false,
    List<String>? myRegisteredCarIds,
  }) {
    return MapEventViewerEntity(
      isCreator: isCreator,
      isOrganizer: isOrganizer,
      canEdit: canEdit,
      attendanceStatus:
          clearAttendance ? null : (attendanceStatus ?? this.attendanceStatus),
      canRsvp: canRsvp,
      canRegisterCars: canRegisterCars,
      myRegisteredCarIds: myRegisteredCarIds ?? this.myRegisteredCarIds,
    );
  }

  @override
  List<Object?> get props => [
        isCreator,
        isOrganizer,
        canEdit,
        attendanceStatus,
        canRsvp,
        canRegisterCars,
        myRegisteredCarIds,
      ];
}

/// A map event in full — `GET /map-events/{id}`, and the response body of very
/// nearly every write in the module.
class MapEventEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String categoryId;
  final String categoryLabel;
  final String locationName;
  final GeoPosition position;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String? coverImageUrl;
  final MapEventStatus status;
  final MapEventApproval approvalStatus;

  /// Why the admin team rejected it. Only ever set alongside
  /// [MapEventApproval.rejected], and only visible to its own organizers.
  final String? rejectionReason;

  /// When true, a car registration lands as `pending` and waits for an
  /// **organizer** (not an admin) to accept or reject it.
  final bool requiresParticipantApproval;

  final int attendeesCount;
  final int attendingCarsCount;
  final int? maxParticipantCapacity;
  final List<MapEventRuleEntity> rules;
  final List<MapEventOrganizerEntity> organizers;

  /// Null for every category except `car_meet`.
  final CarMeetDetailEntity? carMeet;

  final MapEventViewerEntity viewer;
  final DateTime createdAt;

  const MapEventEntity({
    required this.id,
    required this.title,
    required this.description,
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

  bool get isLive => status == MapEventStatus.live;
  bool get isCarMeet => categoryId == 'car_meet';

  /// Whether the entry list is full. The register button greys out on this,
  /// which saves a round trip that the backend would answer with a 409 anyway.
  bool get isAtCapacity {
    final cap = maxParticipantCapacity;
    return cap != null && attendingCarsCount >= cap;
  }

  /// Open spots, or null when the event has no cap. Lets the multi-car picker
  /// clamp how many the viewer can select up front instead of finding out
  /// from a 409 after they've already chosen.
  int? get remainingCapacity {
    final cap = maxParticipantCapacity;
    if (cap == null) return null;
    final remaining = cap - attendingCarsCount;
    return remaining < 0 ? 0 : remaining;
  }

  /// Registration is closed once the deadline passes or the event stops being
  /// actionable. Capacity is checked separately so the UI can say *why*.
  bool get isRegistrationClosed =>
      !status.isActionable || (carMeet?.hasPassed ?? false);

  /// The creator's row, which the "YOU · CREATOR" and delete affordances key
  /// off. Null only for a malformed payload — every event has a creator.
  MapEventOrganizerEntity? get creator {
    for (final o in organizers) {
      if (o.isCreator) return o;
    }
    return null;
  }

  /// Local copy for optimistic RSVP: the button flips immediately and the
  /// server's own [MapEventEntity] overwrites this when it lands.
  MapEventEntity copyWith({
    MapEventAttendance? attendanceStatus,
    bool clearAttendance = false,
    int? attendeesCount,
    MapEventViewerEntity? viewer,
  }) {
    return MapEventEntity(
      id: id,
      title: title,
      description: description,
      categoryId: categoryId,
      categoryLabel: categoryLabel,
      locationName: locationName,
      position: position,
      startsAt: startsAt,
      endsAt: endsAt,
      coverImageUrl: coverImageUrl,
      status: status,
      approvalStatus: approvalStatus,
      rejectionReason: rejectionReason,
      requiresParticipantApproval: requiresParticipantApproval,
      attendeesCount: attendeesCount ?? this.attendeesCount,
      attendingCarsCount: attendingCarsCount,
      maxParticipantCapacity: maxParticipantCapacity,
      rules: rules,
      organizers: organizers,
      carMeet: carMeet,
      viewer: viewer ??
          this.viewer.copyWith(
                attendanceStatus: attendanceStatus,
                clearAttendance: clearAttendance,
              ),
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
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
        requiresParticipantApproval,
        attendeesCount,
        attendingCarsCount,
        maxParticipantCapacity,
        rules,
        organizers,
        carMeet,
        viewer,
        createdAt,
      ];
}
