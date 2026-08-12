import 'package:car_social_media_app/core/services/image_service.dart';
import 'package:car_social_media_app/core/usecases/usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/map_event.dart';
import '../../../domain/usecases/manage_map_event.dart';
import '../../../domain/usecases/map_event_organizers.dart';
import '../../../domain/usecases/map_event_reads.dart';
import '../../utils/map_event_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Backs the "NEW EVENT" form, and the same form in edit mode.
///
/// Submitting is a **sequence**, not one call, because the backend splits the
/// work across three modules:
///
/// 1. `POST /map-events` (or `PATCH` + `PUT /rules` when editing) — this is the
///    step that must succeed; everything after it is decoration on an event
///    that already exists.
/// 2. The cover: presigned slot → PUT the WebP to R2 → `PATCH /cover`. A
///    failure here is reported as a warning, not an error — throwing away a
///    successfully created event because its photo didn't upload would be
///    strictly worse for the user.
/// 3. Co-organizers, which can only be added once there's an id to add them to.
@injectable
class CreateMapEventBloc extends Bloc<CreateMapEventEvent, CreateMapEventState> {
  final GetMapEventCategoriesUseCase getCategories;
  final CreateMapEventUseCase createEvent;
  final UpdateMapEventUseCase updateEvent;
  final ReplaceMapEventRulesUseCase replaceRules;
  final GetMapEventCoverUploadUrlUseCase getCoverUploadUrl;
  final SetMapEventCoverUseCase setCover;
  final AddMapEventOrganizerUseCase addOrganizer;
  final RemoveMapEventOrganizerUseCase removeOrganizer;
  final ImageService imageService;

  /// Backend limits on `PUT /rules`, mirrored here so the form can stop the
  /// user before a round trip does.
  static const maxRules = 50;
  static const maxRuleLength = 300;

  CreateMapEventBloc({
    required this.getCategories,
    required this.createEvent,
    required this.updateEvent,
    required this.replaceRules,
    required this.getCoverUploadUrl,
    required this.setCover,
    required this.addOrganizer,
    required this.removeOrganizer,
    required this.imageService,
  }) : super(const CreateMapEventState()) {
    on<LoadCreateEventRefs>(_onLoadRefs);
    on<ChangeEventTitle>((e, emit) => emit(state.copyWith(title: e.value)));
    on<ChangeEventCategory>(
      (e, emit) => emit(state.copyWith(categoryId: e.categoryId)),
    );
    on<ChangeEventDescription>(
      (e, emit) => emit(state.copyWith(description: e.value)),
    );
    on<ChangeEventLocationName>(
      (e, emit) => emit(state.copyWith(locationName: e.value)),
    );
    on<ChangeEventPosition>(
      (e, emit) => emit(state.copyWith(position: e.position)),
    );
    on<ChangeEventStart>(_onChangeStart);
    on<ChangeEventEnd>(
      (e, emit) => emit(
        state.copyWith(endsAt: e.value, clearEndsAt: e.value == null,
            clearValidation: true),
      ),
    );
    on<ChangeEventCapacity>(
      (e, emit) => emit(
        state.copyWith(capacity: e.value, clearCapacity: e.value == null),
      ),
    );
    on<ToggleEventApproval>(
      (e, emit) => emit(state.copyWith(requiresApproval: e.value)),
    );
    on<ChangeEventDeadline>(
      (e, emit) => emit(
        state.copyWith(
          registrationDeadline: e.value,
          clearDeadline: e.value == null,
          clearValidation: true,
        ),
      ),
    );
    on<ChangeEventCover>(
      (e, emit) => emit(
        state.copyWith(cover: e.image, clearCover: e.image == null),
      ),
    );
    on<AddEventRule>(_onAddRule);
    on<ChangeEventRule>(_onChangeRule);
    on<RemoveEventRule>(_onRemoveRule);
    on<AddEventOrganizer>(_onAddOrganizer);
    on<RemoveEventOrganizer>(_onRemoveOrganizer);
    on<SubmitMapEvent>(_onSubmit);
    on<ClearCreateEventError>(
      (e, emit) => emit(state.copyWith(clearError: true, clearValidation: true)),
    );
  }

  // ── Setup ────────────────────────────────────────────────────────────────

  Future<void> _onLoadRefs(
    LoadCreateEventRefs event,
    Emitter<CreateMapEventState> emit,
  ) async {
    final edit = event.editEvent;
    emit(state.copyWith(status: CreateEventStatus.loading, editEvent: edit));

    final result = await getCategories(NoParams());

    result.fold(
      (failure) => emit(state.copyWith(
        status: CreateEventStatus.failure,
        error: MapEventErrorMapper.from(failure),
      )),
      (categories) => emit(
        state.copyWith(
          status: CreateEventStatus.ready,
          categories: categories,
          // Seed the form from the event being edited; on a fresh form fall
          // back to the first enabled category (today, the only one).
          categoryId: edit?.categoryId ??
              (categories.isNotEmpty ? categories.first.id : state.categoryId),
          title: edit?.title,
          description: edit?.description,
          locationName: edit?.locationName,
          position: edit?.position,
          startsAt: edit?.startsAt,
          endsAt: edit?.endsAt,
          capacity: edit?.maxParticipantCapacity,
          requiresApproval: edit?.requiresParticipantApproval,
          registrationDeadline: edit?.carMeet?.registrationDeadline,
          rules: edit == null ? null : [for (final r in edit.rules) r.rule],
        ),
      ),
    );
  }

  /// Moving the start forward past the end (or past the deadline) would submit
  /// something the backend rejects, so those get pulled along rather than left
  /// to fail validation later.
  void _onChangeStart(
    ChangeEventStart event,
    Emitter<CreateMapEventState> emit,
  ) {
    final end = state.endsAt;
    final deadline = state.registrationDeadline;

    emit(state.copyWith(
      startsAt: event.value,
      endsAt: (end != null && end.isBefore(event.value)) ? null : end,
      clearEndsAt: end != null && end.isBefore(event.value),
      registrationDeadline:
          (deadline != null && deadline.isAfter(event.value)) ? null : deadline,
      clearDeadline: deadline != null && deadline.isAfter(event.value),
      clearValidation: true,
    ));
  }

  // ── Rules ────────────────────────────────────────────────────────────────

  void _onAddRule(AddEventRule event, Emitter<CreateMapEventState> emit) {
    if (state.rules.length >= maxRules) return;
    emit(state.copyWith(rules: [...state.rules, '']));
  }

  void _onChangeRule(ChangeEventRule event, Emitter<CreateMapEventState> emit) {
    if (event.index < 0 || event.index >= state.rules.length) return;
    final rules = [...state.rules];
    rules[event.index] = event.value;
    emit(state.copyWith(rules: rules));
  }

  void _onRemoveRule(RemoveEventRule event, Emitter<CreateMapEventState> emit) {
    if (event.index < 0 || event.index >= state.rules.length) return;
    final rules = [...state.rules]..removeAt(event.index);
    emit(state.copyWith(rules: rules));
  }

  // ── Organizers ───────────────────────────────────────────────────────────

  Future<void> _onAddOrganizer(
    AddEventOrganizer event,
    Emitter<CreateMapEventState> emit,
  ) async {
    final edit = state.editEvent;

    if (edit == null) {
      // No event id yet — queue it and add it after the create call lands.
      final already = state.pendingOrganizers.any(
        (p) => p.candidate.referenceId == event.candidate.referenceId,
      );
      if (already) return;
      emit(state.copyWith(
        pendingOrganizers: [
          ...state.pendingOrganizers,
          PendingOrganizer(event.candidate),
        ],
      ));
      return;
    }

    final result = await addOrganizer(
      AddMapEventOrganizerParams(
        eventId: edit.id,
        type: event.candidate.type,
        referenceId: event.candidate.referenceId,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(error: MapEventErrorMapper.from(failure))),
      (updated) => emit(state.copyWith(editEvent: updated, clearError: true)),
    );
  }

  Future<void> _onRemoveOrganizer(
    RemoveEventOrganizer event,
    Emitter<CreateMapEventState> emit,
  ) async {
    final edit = state.editEvent;

    if (edit == null) {
      emit(state.copyWith(
        pendingOrganizers: [
          for (final p in state.pendingOrganizers)
            if (p.candidate.referenceId != event.id) p,
        ],
      ));
      return;
    }

    final result = await removeOrganizer(
      RemoveMapEventOrganizerParams(eventId: edit.id, organizerId: event.id),
    );

    result.fold(
      (failure) => emit(state.copyWith(error: MapEventErrorMapper.from(failure))),
      (updated) => emit(state.copyWith(editEvent: updated, clearError: true)),
    );
  }

  // ── Submit ───────────────────────────────────────────────────────────────

  Future<void> _onSubmit(
    SubmitMapEvent event,
    Emitter<CreateMapEventState> emit,
  ) async {
    if (state.isSubmitting || !state.isComplete) return;

    final validation = _validate();
    if (validation != null) {
      emit(state.copyWith(validationMessage: validation));
      return;
    }

    emit(state.copyWith(
      status: CreateEventStatus.submitting,
      clearError: true,
      clearValidation: true,
    ));

    var saved = state.isEditing ? await _update(emit) : await _create(emit);
    if (saved == null) return;

    var coverFailed = false;

    final cover = state.cover;
    if (cover != null) {
      final withCover = await _uploadCover(saved.id, cover);
      if (withCover == null) {
        coverFailed = true;
      } else {
        saved = withCover;
      }
    }

    // Queued co-organizers, now that there's an id to attach them to. A
    // failure here is survivable too — the event exists and they can be added
    // again from the manage screen.
    for (final pending in state.pendingOrganizers) {
      final result = await addOrganizer(
        AddMapEventOrganizerParams(
          eventId: saved!.id,
          type: pending.candidate.type,
          referenceId: pending.candidate.referenceId,
        ),
      );
      result.fold(
        (f) => debugPrint('Failed to add organizer after create: ${f.message}'),
        (updated) => saved = updated,
      );
    }

    emit(state.copyWith(
      status: CreateEventStatus.success,
      result: saved,
      coverUploadFailed: coverFailed,
    ));
  }

  /// Returns the saved event, or null after emitting the failure.
  Future<MapEventEntity?> _create(Emitter<CreateMapEventState> emit) async {
    final result = await createEvent(
      CreateMapEventParams(
        categoryId: state.categoryId,
        title: state.title.trim(),
        description: state.description.trim(),
        locationName: state.locationName.trim(),
        position: state.position!,
        startsAt: state.startsAt!,
        endsAt: state.endsAt,
        requiresParticipantApproval: state.requiresApproval,
        registrationDeadline: state.registrationDeadline,
        maxParticipantCapacity: state.capacity,
        rules: _cleanRules(),
      ),
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(
          status: CreateEventStatus.ready,
          error: MapEventErrorMapper.from(failure),
        ));
        return null;
      },
      (created) => created,
    );
  }

  /// Editing takes two calls: `PATCH` for the scalars, `PUT /rules` for the
  /// list — rules are a full replace with no partial form.
  Future<MapEventEntity?> _update(Emitter<CreateMapEventState> emit) async {
    final edit = state.editEvent!;

    final patched = await updateEvent(
      UpdateMapEventParams(
        eventId: edit.id,
        title: state.title.trim(),
        description: state.description.trim(),
        locationName: state.locationName.trim(),
        position: state.position,
        startsAt: state.startsAt,
        endsAt: state.endsAt,
        requiresParticipantApproval: state.requiresApproval,
        registrationDeadline: state.registrationDeadline,
        maxParticipantCapacity: state.capacity,
      ),
    );

    final updated = patched.fold(
      (failure) {
        emit(state.copyWith(
          status: CreateEventStatus.ready,
          error: MapEventErrorMapper.from(failure),
        ));
        return null;
      },
      (e) => e,
    );
    if (updated == null) return null;

    final rules = _cleanRules() ?? const <String>[];
    // Only call PUT /rules when the list actually changed — it deletes and
    // re-inserts every row, so a no-op call churns ids for nothing.
    final unchanged = rules.length == edit.rules.length &&
        [for (var i = 0; i < rules.length; i++) rules[i] == edit.rules[i].rule]
            .every((same) => same);
    if (unchanged) return updated;

    final withRules = await replaceRules(
      ReplaceMapEventRulesParams(eventId: edit.id, rules: rules),
    );

    return withRules.fold(
      (failure) {
        emit(state.copyWith(
          status: CreateEventStatus.ready,
          error: MapEventErrorMapper.from(failure),
        ));
        return null;
      },
      (e) => e,
    );
  }

  /// Presigned slot → PUT the WebP bytes to R2 → hand the key back.
  /// Returns null on any failure; the caller turns that into a warning.
  Future<MapEventEntity?> _uploadCover(
    String eventId,
    CompressedImage cover,
  ) async {
    final slot = await getCoverUploadUrl(eventId);
    final target = slot.fold((_) => null, (s) => s);
    if (target == null) return null;

    try {
      await imageService.uploadToR2(target.uploadUrl, await cover.bytes);
    } catch (e) {
      debugPrint('Event cover upload failed: $e');
      return null;
    }

    final saved = await setCover(
      SetMapEventCoverParams(eventId: eventId, key: target.key),
    );
    return saved.fold((_) => null, (e) => e);
  }

  // ── Validation ───────────────────────────────────────────────────────────

  /// Client-side checks the backend would otherwise answer with a 400. Returns
  /// a key the page localizes, or null when everything is in order.
  String? _validate() {
    final start = state.startsAt;
    final end = state.endsAt;
    final deadline = state.registrationDeadline;
    final capacity = state.capacity;

    if (start != null && end != null && !end.isAfter(start)) {
      return CreateEventValidation.endBeforeStart;
    }
    if (start != null && deadline != null && deadline.isAfter(start)) {
      return CreateEventValidation.deadlineAfterStart;
    }
    if (capacity != null && capacity < 1) {
      return CreateEventValidation.capacityTooSmall;
    }
    return null;
  }

  /// Blank rows are the user adding a rule and not filling it in; they'd be
  /// rejected as non-blank violations, so they're dropped rather than sent.
  List<String>? _cleanRules() {
    final cleaned = [
      for (final rule in state.rules)
        if (rule.trim().isNotEmpty)
          rule.trim().length > maxRuleLength
              ? rule.trim().substring(0, maxRuleLength)
              : rule.trim(),
    ];
    return cleaned.isEmpty ? null : cleaned;
  }
}

/// Keys for the inline validation line. Strings rather than an enum so the
/// state stays trivially comparable, and the page maps them to l10n.
class CreateEventValidation {
  CreateEventValidation._();

  static const endBeforeStart = 'end_before_start';
  static const deadlineAfterStart = 'deadline_after_start';
  static const capacityTooSmall = 'capacity_too_small';
}
