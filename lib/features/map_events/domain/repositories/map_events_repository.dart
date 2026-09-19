import 'package:tweakd/core/error/base_failures.dart';
import 'package:tweakd/features/map/domain/entities/geo_position.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../entities/geocode_candidate.dart';
import '../entities/map_event.dart';
import '../entities/map_event_attendee.dart';
import '../entities/map_event_category.dart';
import '../entities/map_event_enums.dart';
import '../entities/map_event_page.dart';
import '../entities/map_event_participant.dart';
import '../entities/map_event_pin.dart';
import '../entities/map_event_summary.dart';
import '../entities/map_event_withdrawal_request.dart';
import '../entities/organizer_candidate.dart';

/// Everything the app consumes from `/api/v1/map-events/*` plus the cover-image
/// slot of the storage module.
///
/// The admin review endpoints (`/api/v1/admin/map-events/*`) are deliberately
/// absent — they belong to the admin web dashboard, not this app.
abstract class MapEventsRepository {
  // ── Reads ────────────────────────────────────────────────────────────────

  /// Event pins within [radiusKm] of [centre].
  ///
  /// Array order is unspecified (the backend's own answers conflicted), so
  /// callers must never treat position in the list as meaningful.
  Future<Either<Failure, List<MapEventPinEntity>>> getNearbyEvents({
    required GeoPosition centre,
    required double radiusKm,
    String? categoryId,
    int? limit,
    CancelToken? cancelToken,
  });

  /// The map's search box: approved events whose title, category or venue
  /// contains [query], nearest to [centre] first, anywhere on the map.
  ///
  /// [statuses] picks the phases (`upcoming` / `live` / `previous` only —
  /// anything else is refused by the backend); empty means upcoming + live.
  /// Each returned pin's status is the *clock-derived* phase, so a meet that
  /// started an hour ago comes back as live even though nothing ever stored
  /// that. Continue with the previous page's cursor and the same inputs.
  Future<Either<Failure, MapEventPageEntity<MapEventPinEntity>>> searchEvents({
    required String query,
    required GeoPosition centre,
    Set<MapEventStatus> statuses,
    String? cursor,
    int? size,
    CancelToken? cancelToken,
  });

  /// Categories that can actually be created today — enabled ones only.
  Future<Either<Failure, List<MapEventCategoryEntity>>> getCategories();

  Future<Either<Failure, MapEventEntity>> getEvent(
    String eventId, {
    CancelToken? cancelToken,
  });

  Future<Either<Failure, MapEventPageEntity<MapEventSummaryEntity>>> getMyEvents({
    String? cursor,
    int size,
  });

  Future<Either<Failure, MapEventPageEntity<MapEventAttendeeEntity>>> getAttendees(
    String eventId, {
    MapEventAttendance? status,
    String? cursor,
    int size,
  });

  /// Cars registered for an event.
  ///
  /// Pass [status] explicitly: with no filter the backend returns accepted
  /// **and** withdrawn rows together, which is not the "N approved" entry list
  /// the design asks for. `pending` and `rejected` are organizer-only.
  Future<Either<Failure, MapEventPageEntity<MapEventParticipantEntity>>> getCars(
    String eventId, {
    MapEventParticipation? status,
    String? cursor,
    int size,
  });

  /// The caller's own entries for an event, whatever their status, in one
  /// unpaginated list. The only way a plain participant can read their own
  /// pending or rejected row — [getCars] keeps those slices to organizers.
  Future<Either<Failure, List<MapEventParticipantEntity>>> getMyCars(
    String eventId, {
    CancelToken? cancelToken,
  });

  Future<Either<Failure, List<OrganizerCandidateEntity>>> searchOrganizers(
    String query, {
    CancelToken? cancelToken,
  });

  /// Structured forward geocoding for the location picker — up to five
  /// candidates, best match first.
  ///
  /// The returned coordinates are a camera hint only. The event's own
  /// coordinate is the one the user taps onto the map, so nothing Mapbox
  /// returns here is ever persisted.
  Future<Either<Failure, List<GeocodeCandidateEntity>>> searchLocation({
    required String city,
    required String street,
    required String addressNumber,
    CancelToken? cancelToken,
  });

  /// Organizer-only. Pending withdrawal requests, grouped by owner.
  Future<Either<Failure, List<MapEventWithdrawalRequestEntity>>> getWithdrawals(
    String eventId,
  );

  // ── Event writes ─────────────────────────────────────────────────────────

  /// Creates an event in `approval_status: pending`.
  ///
  /// [registrationDeadline] is required when [categoryId] is `car_meet`, even
  /// though the design labels it optional — the API wins.
  Future<Either<Failure, MapEventEntity>> createEvent({
    required String categoryId,
    required String title,
    required String description,
    required String locationName,
    required GeoPosition position,
    required DateTime startsAt,
    DateTime? endsAt,
    required bool requiresParticipantApproval,
    DateTime? registrationDeadline,
    int? maxParticipantCapacity,
    List<String>? rules,
  });

  /// Partial update, allowed only while the event is pending or rejected.
  /// Every null field means "leave it alone" — including
  /// [maxParticipantCapacity], which therefore cannot be cleared back to
  /// unlimited (see `MAP_EVENTS_NOTES.md` §1.6).
  Future<Either<Failure, MapEventEntity>> updateEvent(
    String eventId, {
    String? title,
    String? description,
    String? locationName,
    GeoPosition? position,
    DateTime? startsAt,
    DateTime? endsAt,
    bool? requiresParticipantApproval,
    DateTime? registrationDeadline,
    int? maxParticipantCapacity,
  });

  /// Full replace of the rules list — `sort_order` is assigned server-side from
  /// list position, and an empty list clears them all.
  Future<Either<Failure, MapEventEntity>> replaceRules(
    String eventId,
    List<String> rules,
  );

  /// Two-step cover upload: ask for a presigned slot, PUT the WebP bytes to R2,
  /// then hand the key back with [setCover].
  Future<Either<Failure, ({String key, String uploadUrl})>> getCoverUploadUrl(
    String eventId,
  );

  Future<Either<Failure, MapEventEntity>> setCover(String eventId, String key);

  Future<Either<Failure, MapEventEntity>> cancelEvent(String eventId);

  Future<Either<Failure, MapEventEntity>> finishEvent(String eventId);

  /// Creator only.
  Future<Either<Failure, Unit>> deleteEvent(String eventId);

  // ── Organizers ───────────────────────────────────────────────────────────

  /// Creator only. Exactly one of [userId] / [businessId] must be set — feed
  /// the candidate's `referenceId` into the field matching its type.
  Future<Either<Failure, MapEventEntity>> addOrganizer(
    String eventId, {
    String? userId,
    String? businessId,
  });

  Future<Either<Failure, MapEventEntity>> removeOrganizer(
    String eventId,
    String organizerId,
  );

  // ── Attendance & participation ───────────────────────────────────────────

  Future<Either<Failure, MapEventEntity>> setAttendance(
    String eventId,
    MapEventAttendance status,
  );

  Future<Either<Failure, MapEventEntity>> clearAttendance(String eventId);

  /// Every participation write answers with the whole event, so the counts and
  /// viewer flags a write moves come back in the same response. Only the
  /// caller's own entry rows still need [getMyCars] afterwards.
  Future<Either<Failure, MapEventEntity>> registerCar(
    String eventId,
    String carId,
  );

  /// Cancels a **not yet accepted** registration. An accepted entry must go
  /// through [withdraw] instead — calling this on one errors.
  Future<Either<Failure, MapEventEntity>> cancelCarRegistration(
    String eventId,
    String carId,
  );

  /// Organizer only: accept or reject a pending car entry. [reason] is
  /// required when [status] is [MapEventParticipation.rejected] — the backend
  /// 400s without one — and ignored otherwise.
  Future<Either<Failure, MapEventEntity>> reviewCarRegistration(
    String eventId,
    String carId,
    MapEventParticipation status, {
    String? reason,
  });

  /// Flags **all** the caller's cars in the event as `withdrawn`, pending
  /// organizer review. One-way: nothing lets the participant take it back, and
  /// there is no way to withdraw a single car.
  Future<Either<Failure, MapEventEntity>> withdraw(
    String eventId, {
    String? note,
  });

  /// Organizer only. Hard-deletes the owner's rows.
  Future<Either<Failure, MapEventEntity>> approveWithdrawal(
    String eventId,
    String ownerId,
  );

  /// Organizer only. Reverts the owner's rows to `accepted`.
  Future<Either<Failure, MapEventEntity>> rejectWithdrawal(
    String eventId,
    String ownerId,
  );
}
