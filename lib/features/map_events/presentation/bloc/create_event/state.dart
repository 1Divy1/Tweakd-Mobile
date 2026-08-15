import 'package:car_social_media_app/core/services/image_service.dart';
import 'package:car_social_media_app/features/map/domain/entities/geo_position.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/map_event.dart';
import '../../../domain/entities/map_event_category.dart';
import '../../../domain/entities/organizer_candidate.dart';
import '../../utils/map_event_error_mapper.dart';

enum CreateEventStatus {
  /// Fetching the category list.
  loading,

  /// The form is usable.
  ready,

  /// A create/update is in flight — the whole form goes inert.
  submitting,

  /// Done. The page swaps to the "sent for review" confirmation.
  success,

  /// The category list failed; there's no usable form without it.
  failure,
}

/// A co-organizer the user has picked but who isn't on the event yet — the
/// backend can only be told about them once the event has an id.
class PendingOrganizer extends Equatable {
  final OrganizerCandidateEntity candidate;

  const PendingOrganizer(this.candidate);

  @override
  List<Object?> get props => [candidate];
}

class CreateMapEventState extends Equatable {
  final CreateEventStatus status;

  /// The event being edited, or null when creating. Editing is only allowed
  /// while the event is pending or rejected — the page guards on that.
  final MapEventEntity? editEvent;

  final List<MapEventCategoryEntity> categories;

  // ── Form ────────────────────────────────────────────────────────────────
  final String title;
  final String categoryId;
  final String description;
  final String locationName;
  final GeoPosition? position;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final int? capacity;
  final bool requiresApproval;
  final DateTime? registrationDeadline;
  final CompressedImage? cover;
  final List<String> rules;

  /// Organizers queued in create mode. In edit mode the event's own
  /// `organizers` list is the source of truth and this stays empty.
  final List<PendingOrganizer> pendingOrganizers;

  /// Set when the cover upload fails *after* the event was created: the event
  /// exists, so this is a warning on the success screen, not a failure.
  final bool coverUploadFailed;

  final MapEventError? error;

  /// A client-side validation message, shown inline rather than in a snackbar.
  final String? validationMessage;

  /// The created (or updated) event, available once [status] is success.
  final MapEventEntity? result;

  const CreateMapEventState({
    this.status = CreateEventStatus.loading,
    this.editEvent,
    this.categories = const [],
    this.title = '',
    this.categoryId = MapEventCategoryEntity.carMeetId,
    this.description = '',
    this.locationName = '',
    this.position,
    this.startsAt,
    this.endsAt,
    this.capacity,
    this.requiresApproval = true,
    this.registrationDeadline,
    this.cover,
    this.rules = const [],
    this.pendingOrganizers = const [],
    this.coverUploadFailed = false,
    this.error,
    this.validationMessage,
    this.result,
  });

  bool get isEditing => editEvent != null;
  bool get isSubmitting => status == CreateEventStatus.submitting;

  /// Car meets are the one category with a mandatory registration deadline —
  /// the API enforces it even though the design labels the field optional.
  bool get requiresDeadline => categoryId == MapEventCategoryEntity.carMeetId;

  /// A cover is mandatory (owner's call — no event without one). A freshly
  /// picked image counts, and so does the one an event being edited already
  /// has: editing doesn't force a re-pick.
  bool get hasCover =>
      cover != null || (editEvent?.coverImageUrl?.isNotEmpty ?? false);

  /// What the bottom CTA needs before it will do anything. Deliberately the
  /// minimum the backend demands, so the button doesn't gate on taste.
  bool get isComplete =>
      title.trim().isNotEmpty &&
      locationName.trim().isNotEmpty &&
      position != null &&
      startsAt != null &&
      hasCover &&
      (!requiresDeadline || registrationDeadline != null);

  /// Which of the missing pieces to name on the CTA. Location and start time
  /// are grouped because they're the ones people forget together; the cover
  /// and the deadline each get their own message since they're easy to miss.
  bool get isMissingDeadlineOnly =>
      requiresDeadline &&
      registrationDeadline == null &&
      hasCover &&
      title.trim().isNotEmpty &&
      locationName.trim().isNotEmpty &&
      position != null &&
      startsAt != null;

  bool get isMissingCoverOnly =>
      !hasCover &&
      title.trim().isNotEmpty &&
      locationName.trim().isNotEmpty &&
      position != null &&
      startsAt != null &&
      (!requiresDeadline || registrationDeadline != null);

  CreateMapEventState copyWith({
    CreateEventStatus? status,
    MapEventEntity? editEvent,
    List<MapEventCategoryEntity>? categories,
    String? title,
    String? categoryId,
    String? description,
    String? locationName,
    GeoPosition? position,
    DateTime? startsAt,
    DateTime? endsAt,
    bool clearEndsAt = false,
    int? capacity,
    bool clearCapacity = false,
    bool? requiresApproval,
    DateTime? registrationDeadline,
    bool clearDeadline = false,
    CompressedImage? cover,
    bool clearCover = false,
    List<String>? rules,
    List<PendingOrganizer>? pendingOrganizers,
    bool? coverUploadFailed,
    MapEventError? error,
    bool clearError = false,
    String? validationMessage,
    bool clearValidation = false,
    MapEventEntity? result,
  }) {
    return CreateMapEventState(
      status: status ?? this.status,
      editEvent: editEvent ?? this.editEvent,
      categories: categories ?? this.categories,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      locationName: locationName ?? this.locationName,
      position: position ?? this.position,
      startsAt: startsAt ?? this.startsAt,
      endsAt: clearEndsAt ? null : (endsAt ?? this.endsAt),
      capacity: clearCapacity ? null : (capacity ?? this.capacity),
      requiresApproval: requiresApproval ?? this.requiresApproval,
      registrationDeadline: clearDeadline
          ? null
          : (registrationDeadline ?? this.registrationDeadline),
      cover: clearCover ? null : (cover ?? this.cover),
      rules: rules ?? this.rules,
      pendingOrganizers: pendingOrganizers ?? this.pendingOrganizers,
      coverUploadFailed: coverUploadFailed ?? this.coverUploadFailed,
      error: clearError ? null : (error ?? this.error),
      validationMessage:
          clearValidation ? null : (validationMessage ?? this.validationMessage),
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props => [
        status,
        editEvent,
        categories,
        title,
        categoryId,
        description,
        locationName,
        position,
        startsAt,
        endsAt,
        capacity,
        requiresApproval,
        registrationDeadline,
        cover?.path,
        rules,
        pendingOrganizers,
        coverUploadFailed,
        error,
        validationMessage,
        result,
      ];
}
