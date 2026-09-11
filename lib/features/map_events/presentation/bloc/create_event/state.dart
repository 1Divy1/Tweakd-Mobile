import 'package:tweakd/core/services/image_service.dart';
import 'package:tweakd/features/map/domain/entities/geo_position.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/contest.dart';
import '../../../domain/entities/map_event.dart';
import '../../../domain/entities/map_event_category.dart';
import '../../../domain/entities/organizer_candidate.dart';
import '../../utils/map_event_error_mapper.dart';
import '../create_contest/state.dart';

enum CreateEventStatus {
  /// Fetching the category lists and any saved draft.
  loading,

  /// The form is usable.
  ready,

  /// A create/update is in flight — the whole wizard goes inert.
  submitting,

  /// Done. The page swaps to the "sent for review" confirmation.
  success,

  /// The category list failed; there's no usable form without it.
  failure,
}

/// The wizard's screens, in order.
///
/// [contests] is skipped in edit mode: an event that already exists manages its
/// contests from the manage screen, which owns the real create/edit/delete
/// flow against the server rather than a local draft list.
enum CreateEventStep {
  basics,
  organizers,
  whenWhere,
  rules,
  contests,
  cover,
  review,
}

/// A co-organizer the user has picked but who isn't on the event yet — the
/// backend can only be told about them once the event has an id.
class PendingOrganizer extends Equatable {
  final OrganizerCandidateEntity candidate;

  const PendingOrganizer(this.candidate);

  @override
  List<Object?> get props => [candidate];
}

/// A contest lined up on the CONTESTS step, before the event it belongs to
/// exists.
///
/// The opening time is held as a *choice* rather than an instant, exactly as
/// [CreateContestCubit] holds it, because the event's own schedule is still
/// editable at this point — going back to WHEN & WHERE and moving the start has
/// to move "at the start of the meet" with it. It's resolved to an instant
/// once, at submit, by [resolve]. The closing time is a plain instant: only a
/// label attendees see, so it doesn't need to track the schedule.
class PendingContest extends Equatable {
  /// Identifies the row while it is local-only. Not sent anywhere.
  final String localId;

  final String categoryId;

  /// Kept alongside the id so the list renders without a category lookup.
  final String categoryLabel;

  final String title;
  final String criteria;
  final ContestOpensChoice opensChoice;
  final DateTime? customOpensAt;

  /// When voting is *planned* to close — a label attendees see. Nothing acts on
  /// it; the organizer opens and closes voting by hand. Null only on drafts
  /// saved before this field existed; [resolve] falls back for those.
  final DateTime? closesAt;

  const PendingContest({
    required this.localId,
    required this.categoryId,
    required this.categoryLabel,
    required this.title,
    required this.criteria,
    required this.opensChoice,
    required this.customOpensAt,
    required this.closesAt,
  });

  /// The instants this draft means against the event's final schedule. Mirrors
  /// `CreateContestCubit.resolveTimes`, which does the same arithmetic for a
  /// contest added to an event that already exists.
  ({DateTime opensAt, DateTime closesAt}) resolve(
    DateTime startsAt,
    DateTime? endsAt,
  ) {
    final now = DateTime.now();
    final opensAt = switch (opensChoice) {
      ContestOpensChoice.now => now,
      ContestOpensChoice.atEventStart =>
        startsAt.isAfter(now) ? startsAt : now,
      ContestOpensChoice.custom => customOpensAt ?? now,
    };
    final end = endsAt ?? startsAt.add(const Duration(hours: 24));
    final resolvedCloses = closesAt ?? end.subtract(const Duration(hours: 1));
    return (opensAt: opensAt, closesAt: resolvedCloses);
  }

  PendingContest copyWith({
    String? categoryId,
    String? categoryLabel,
    String? title,
    String? criteria,
    ContestOpensChoice? opensChoice,
    DateTime? customOpensAt,
    DateTime? closesAt,
  }) {
    return PendingContest(
      localId: localId,
      categoryId: categoryId ?? this.categoryId,
      categoryLabel: categoryLabel ?? this.categoryLabel,
      title: title ?? this.title,
      criteria: criteria ?? this.criteria,
      opensChoice: opensChoice ?? this.opensChoice,
      customOpensAt: customOpensAt ?? this.customOpensAt,
      closesAt: closesAt ?? this.closesAt,
    );
  }

  @override
  List<Object?> get props => [
        localId,
        categoryId,
        categoryLabel,
        title,
        criteria,
        opensChoice,
        customOpensAt,
        closesAt,
      ];
}

class CreateMapEventState extends Equatable {
  final CreateEventStatus status;

  /// The event being edited, or null when creating. Editing is only allowed
  /// while the event is pending or rejected — the page guards on that.
  final MapEventEntity? editEvent;

  final List<MapEventCategoryEntity> categories;

  /// Contest categories, for the CONTESTS step. Empty in edit mode, where that
  /// step doesn't run.
  final List<ContestCategoryEntity> contestCategories;

  // ── Form ────────────────────────────────────────────────────────────────
  final String title;
  final String categoryId;
  final String description;

  /// What `location_name` is sent as. Composed from [city] / [street] /
  /// [number] when the map picker has run; in edit mode it starts as whatever
  /// the saved event carries, since an existing event has no components.
  final String locationName;

  /// The three address parts the picker collected, shown back to the organizer
  /// on their own lines. Empty until a location is picked.
  final String city;
  final String street;
  final String number;

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

  /// Contests queued in create mode, flushed after the event is created.
  final List<PendingContest> pendingContests;

  /// Set when the cover upload fails *after* the event was created: the event
  /// exists, so this is a warning on the success screen, not a failure.
  final bool coverUploadFailed;

  /// How many queued contests failed to be created after the event was. Same
  /// rule as the cover: a warning, not a failed event.
  final int contestsFailed;

  final MapEventError? error;

  /// A client-side validation message, shown inline rather than in a snackbar.
  final String? validationMessage;

  /// True when this form was seeded from a saved local draft, so the wizard can
  /// say so once rather than silently resurrecting old input.
  final bool restoredFromDraft;

  /// The created (or updated) event, available once [status] is success.
  final MapEventEntity? result;

  const CreateMapEventState({
    this.status = CreateEventStatus.loading,
    this.editEvent,
    this.categories = const [],
    this.contestCategories = const [],
    this.title = '',
    this.categoryId = MapEventCategoryEntity.carMeetId,
    this.description = '',
    this.locationName = '',
    this.city = '',
    this.street = '',
    this.number = '',
    this.position,
    this.startsAt,
    this.endsAt,
    this.capacity,
    this.requiresApproval = true,
    this.registrationDeadline,
    this.cover,
    this.rules = const [],
    this.pendingOrganizers = const [],
    this.pendingContests = const [],
    this.coverUploadFailed = false,
    this.contestsFailed = 0,
    this.error,
    this.validationMessage,
    this.restoredFromDraft = false,
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

  String? get existingCoverUrl {
    final url = editEvent?.coverImageUrl;
    return (url == null || url.isEmpty) ? null : url;
  }

  /// The steps this run of the wizard actually shows. Editing skips CONTESTS.
  List<CreateEventStep> get steps => [
        for (final step in CreateEventStep.values)
          if (!(isEditing && step == CreateEventStep.contests)) step,
      ];

  /// What the final CTA needs before it will do anything. Deliberately the
  /// minimum the backend demands, so the button doesn't gate on taste.
  bool get isComplete => [
        for (final step in steps)
          if (step != CreateEventStep.review) blockerFor(step),
      ].every((blocker) => blocker == null);

  /// The one thing stopping the wizard leaving [step], as a key the page
  /// localizes, or null when the step is in order.
  ///
  /// Every rule here is one the backend would otherwise answer with a 400 —
  /// `CreateMapEventRequest` marks title, description and location `@NotBlank`,
  /// and a car meet's registration deadline is required. Nothing gates on
  /// taste: ORGANIZERS, RULES' rule list and CONTESTS are all skippable.
  String? blockerFor(CreateEventStep step) {
    switch (step) {
      case CreateEventStep.basics:
        if (title.trim().isEmpty) return CreateEventValidation.titleRequired;
        if (description.trim().isEmpty) {
          return CreateEventValidation.descriptionRequired;
        }
        return null;

      case CreateEventStep.organizers:
        return null;

      case CreateEventStep.whenWhere:
        if (startsAt == null) return CreateEventValidation.startRequired;
        if (position == null || locationName.trim().isEmpty) {
          return CreateEventValidation.locationRequired;
        }
        final start = startsAt!;
        final end = endsAt;
        if (end != null && !end.isAfter(start)) {
          return CreateEventValidation.endBeforeStart;
        }
        if (requiresDeadline && registrationDeadline == null) {
          return CreateEventValidation.deadlineRequired;
        }
        final deadline = registrationDeadline;
        if (deadline != null && deadline.isAfter(start)) {
          return CreateEventValidation.deadlineAfterStart;
        }
        return null;

      case CreateEventStep.rules:
        if (capacity != null && capacity! < 1) {
          return CreateEventValidation.capacityTooSmall;
        }
        return null;

      case CreateEventStep.contests:
        return null;

      case CreateEventStep.cover:
        if (!hasCover) return CreateEventValidation.coverRequired;
        return null;

      case CreateEventStep.review:
        return null;
    }
  }

  CreateMapEventState copyWith({
    CreateEventStatus? status,
    MapEventEntity? editEvent,
    List<MapEventCategoryEntity>? categories,
    List<ContestCategoryEntity>? contestCategories,
    String? title,
    String? categoryId,
    String? description,
    String? locationName,
    String? city,
    String? street,
    String? number,
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
    List<PendingContest>? pendingContests,
    bool? coverUploadFailed,
    int? contestsFailed,
    MapEventError? error,
    bool clearError = false,
    String? validationMessage,
    bool clearValidation = false,
    bool? restoredFromDraft,
    MapEventEntity? result,
  }) {
    return CreateMapEventState(
      status: status ?? this.status,
      editEvent: editEvent ?? this.editEvent,
      categories: categories ?? this.categories,
      contestCategories: contestCategories ?? this.contestCategories,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      locationName: locationName ?? this.locationName,
      city: city ?? this.city,
      street: street ?? this.street,
      number: number ?? this.number,
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
      pendingContests: pendingContests ?? this.pendingContests,
      coverUploadFailed: coverUploadFailed ?? this.coverUploadFailed,
      contestsFailed: contestsFailed ?? this.contestsFailed,
      error: clearError ? null : (error ?? this.error),
      validationMessage:
          clearValidation ? null : (validationMessage ?? this.validationMessage),
      restoredFromDraft: restoredFromDraft ?? this.restoredFromDraft,
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props => [
        status,
        editEvent,
        categories,
        contestCategories,
        title,
        categoryId,
        description,
        locationName,
        city,
        street,
        number,
        position,
        startsAt,
        endsAt,
        capacity,
        requiresApproval,
        registrationDeadline,
        cover?.path,
        rules,
        pendingOrganizers,
        pendingContests,
        coverUploadFailed,
        contestsFailed,
        error,
        validationMessage,
        restoredFromDraft,
        result,
      ];
}

/// Keys for the inline validation line. Strings rather than an enum so the
/// state stays trivially comparable, and the page maps them to l10n.
class CreateEventValidation {
  CreateEventValidation._();

  static const titleRequired = 'title_required';
  static const descriptionRequired = 'description_required';
  static const locationRequired = 'location_required';
  static const startRequired = 'start_required';
  static const deadlineRequired = 'deadline_required';
  static const coverRequired = 'cover_required';
  static const endBeforeStart = 'end_before_start';
  static const deadlineAfterStart = 'deadline_after_start';
  static const capacityTooSmall = 'capacity_too_small';
}
