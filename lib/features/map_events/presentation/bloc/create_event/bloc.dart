import 'package:tweakd/core/services/image_service.dart';
import 'package:tweakd/core/usecases/usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/datasources/create_event_draft_local_data_source.dart';
import '../../../domain/entities/contest.dart';
import '../../../domain/entities/map_event.dart';
import '../../../domain/usecases/manage_map_event.dart';
import '../../../domain/usecases/map_event_contests.dart';
import '../../../domain/usecases/map_event_organizers.dart';
import '../../../domain/usecases/map_event_reads.dart';
import '../../utils/create_event_draft.dart';
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
  final GetContestCategoriesUseCase getContestCategories;
  final CreateContestUseCase createContest;
  final ImageService imageService;
  final CreateEventDraftLocalDataSource draftStore;

  /// Backend limits on `PUT /rules`, mirrored here so the form can stop the
  /// user before a round trip does.
  static const maxRules = 50;
  static const maxRuleLength = 300;

  /// `MapEventContestsServiceImpl.MAX_CONTESTS_PER_EVENT`, mirrored so the
  /// CONTESTS step caps the draft list rather than failing at flush time, once
  /// the event already exists and the wizard is gone.
  static const maxContests = 20;

  CreateMapEventBloc({
    required this.getCategories,
    required this.createEvent,
    required this.updateEvent,
    required this.replaceRules,
    required this.getCoverUploadUrl,
    required this.setCover,
    required this.addOrganizer,
    required this.removeOrganizer,
    required this.getContestCategories,
    required this.createContest,
    required this.imageService,
    required this.draftStore,
  }) : super(const CreateMapEventState()) {
    on<LoadCreateEventRefs>(_onLoadRefs);
    on<ChangeEventTitle>((e, emit) => emit(state.copyWith(title: e.value)));
    on<ChangeEventCategory>(
      (e, emit) => emit(state.copyWith(categoryId: e.categoryId)),
    );
    on<ChangeEventDescription>(
      (e, emit) => emit(state.copyWith(description: e.value)),
    );
    on<ChangeEventLocation>(
      (e, emit) => emit(
        state.copyWith(
          position: e.picked.position,
          city: e.picked.city,
          street: e.picked.street,
          number: e.picked.number,
          locationName: e.picked.addressLabel,
        ),
      ),
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
    on<AddDraftContest>(_onAddDraftContest);
    on<UpdateDraftContest>(_onUpdateDraftContest);
    on<RemoveDraftContest>(_onRemoveDraftContest);
    on<DiscardEventDraft>(_onDiscardDraft);
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

    // Contest categories back the CONTESTS step, which edit mode doesn't run —
    // and a failure here must not block the wizard, since the step is optional.
    // The step shows its own empty state when the list didn't arrive.
    final contestCategories = edit != null
        ? const <ContestCategoryEntity>[]
        : (await getContestCategories(NoParams())).fold(
            (failure) {
              debugPrint('Contest categories unavailable: ${failure.message}');
              return const <ContestCategoryEntity>[];
            },
            (categories) => categories,
          );

    result.fold(
      (failure) => emit(state.copyWith(
        status: CreateEventStatus.failure,
        error: MapEventErrorMapper.from(failure),
      )),
      (categories) => emit(
        state.copyWith(
          status: CreateEventStatus.ready,
          categories: categories,
          contestCategories: contestCategories,
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

    if (state.status == CreateEventStatus.ready) await _restoreDraft(emit);
  }

  /// Lays a saved draft over the freshly loaded form.
  ///
  /// Create mode only. Restoring a stale draft over a live event in edit mode
  /// would silently reintroduce fields the organizer has already changed on the
  /// server, which is worse than losing the draft.
  Future<void> _restoreDraft(Emitter<CreateMapEventState> emit) async {
    if (state.isEditing) return;

    final draft = await draftStore.read();
    if (draft == null || !CreateEventDraft.isWorthRestoring(draft)) return;

    emit(CreateEventDraft.decode(draft, state, imageService));
  }

  /// Every change to a usable form is written straight back to disk.
  ///
  /// No debounce: the writes are small, they go through
  /// [CreateEventDraftLocalDataSource], which swallows its own failures, and a
  /// timer would mean the one keystroke before a crash is the one that is lost.
  @override
  void onChange(Change<CreateMapEventState> change) {
    super.onChange(change);
    final next = change.nextState;
    if (next.isEditing) return;
    if (next.status != CreateEventStatus.ready) return;
    draftStore.write(CreateEventDraft.encode(next));
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

  // ── Draft contests ───────────────────────────────────────────────────────

  void _onAddDraftContest(
    AddDraftContest event,
    Emitter<CreateMapEventState> emit,
  ) {
    if (state.pendingContests.length >= maxContests) return;
    emit(state.copyWith(
      pendingContests: [...state.pendingContests, event.contest],
    ));
  }

  void _onUpdateDraftContest(
    UpdateDraftContest event,
    Emitter<CreateMapEventState> emit,
  ) {
    emit(state.copyWith(
      pendingContests: [
        for (final contest in state.pendingContests)
          contest.localId == event.contest.localId ? event.contest : contest,
      ],
    ));
  }

  void _onRemoveDraftContest(
    RemoveDraftContest event,
    Emitter<CreateMapEventState> emit,
  ) {
    emit(state.copyWith(
      pendingContests: [
        for (final contest in state.pendingContests)
          if (contest.localId != event.localId) contest,
      ],
    ));
  }

  // ── Draft ────────────────────────────────────────────────────────────────

  Future<void> _onDiscardDraft(
    DiscardEventDraft event,
    Emitter<CreateMapEventState> emit,
  ) async {
    await draftStore.clear();
    // Rebuilt rather than copyWith-ed: the point is to clear fields, and
    // copyWith's null-means-unchanged contract can't express that.
    emit(CreateMapEventState(
      status: CreateEventStatus.ready,
      categories: state.categories,
      contestCategories: state.contestCategories,
      categoryId: state.categories.isNotEmpty
          ? state.categories.first.id
          : state.categoryId,
    ));
  }

  // ── Submit ───────────────────────────────────────────────────────────────

  Future<void> _onSubmit(
    SubmitMapEvent event,
    Emitter<CreateMapEventState> emit,
  ) async {
    if (state.isSubmitting) return;

    // The wizard gates each step on the way through, so reaching REVIEW should
    // mean everything is in order. Re-checking here is what makes the submit
    // path safe on its own — a restored draft lands on a filled form the user
    // may never have stepped through.
    for (final step in state.steps) {
      final blocker = state.blockerFor(step);
      if (blocker != null) {
        emit(state.copyWith(validationMessage: blocker));
        return;
      }
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

    final contestsFailed = await _flushContests(saved!);

    // The event exists and is on its way to review; the draft has done its job.
    await draftStore.clear();

    emit(state.copyWith(
      status: CreateEventStatus.success,
      result: saved,
      coverUploadFailed: coverFailed,
      contestsFailed: contestsFailed,
    ));
  }

  /// Creates the contests queued on the CONTESTS step, now that there's an id
  /// to hang them on, and returns how many failed.
  ///
  /// Failures are counted rather than thrown: the event is already created and
  /// under review, and the organizer can add the missing contests from the
  /// manage screen. Losing the event over a contest would be strictly worse.
  ///
  /// This is the call that needs the backend's authoring guard to accept a
  /// *pending* event — see `MapEventContestsServiceImpl.requireEventNotFinished`.
  Future<int> _flushContests(MapEventEntity saved) async {
    if (state.pendingContests.isEmpty) return 0;

    var failed = 0;
    for (final pending in state.pendingContests) {
      final times = pending.resolve(saved.startsAt, saved.endsAt);
      final criteria = pending.criteria.trim();

      final result = await createContest(
        CreateContestParams(
          eventId: saved.id,
          categoryId: pending.categoryId,
          title: pending.title.trim(),
          criteria: criteria.isEmpty ? null : criteria,
          opensAt: times.opensAt,
          closesAt: times.closesAt,
        ),
      );

      result.fold(
        (f) {
          failed++;
          debugPrint('Failed to create contest after event create: ${f.message}');
        },
        (_) {},
      );
    }
    return failed;
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
