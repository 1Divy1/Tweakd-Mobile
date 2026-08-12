import 'package:car_social_media_app/core/network/abstract_http.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/map_event_json.dart';
import '../models/map_event_list_models.dart';
import '../models/map_event_model.dart';
import '../models/map_event_pin_model.dart';

/// The user-facing half of `/api/v1/map-events/*`.
///
/// The admin review endpoints (`/api/v1/admin/map-events/*`) are intentionally
/// not here — they belong to the admin web dashboard.
///
/// Bodies are built with explicit maps rather than a model's `toJson`, because
/// several endpoints treat *absent* and *null* differently (a PATCH omits what
/// it doesn't change) and that distinction is easier to keep honest inline.
@lazySingleton
class MapEventsApiDataSource {
  final AbstractHTTP http;

  MapEventsApiDataSource(this.http);

  // ── Reads ────────────────────────────────────────────────────────────────

  /// Flat array — not a page. Order is unspecified; never rely on it.
  Future<List<MapEventPinModel>> getNearby({
    required double lat,
    required double lng,
    required double radiusKm,
    String? categoryId,
    int? limit,
    CancelToken? cancelToken,
  }) async {
    final data = await http.get(
      '/map-events/nearby',
      queryParameters: {
        'lat': lat,
        'lng': lng,
        'radius_km': radiusKm,
        'category': ?categoryId,
        'limit': ?limit,
      },
      cancelToken: cancelToken,
    );

    return [
      for (final e in data as List<dynamic>)
        MapEventPinModel.fromJson(e as Map<String, dynamic>),
    ];
  }

  Future<List<MapEventCategoryModel>> getCategories() async {
    final data = await http.get('/map-events/categories');
    return [
      for (final e in data as List<dynamic>)
        MapEventCategoryModel.fromJson(e as Map<String, dynamic>),
    ];
  }

  Future<MapEventModel> getEvent(
    String eventId, {
    CancelToken? cancelToken,
  }) async {
    final data = await http.get('/map-events/$eventId', cancelToken: cancelToken);
    return MapEventModel.fromJson(data as Map<String, dynamic>);
  }

  Future<MapEventPageModel<MapEventSummaryModel>> getMyEvents({
    String? cursor,
    int size = 20,
  }) async {
    final data = await http.get(
      '/map-events/mine',
      queryParameters: {'cursor': ?cursor, 'size': size},
    );
    return MapEventPageModel.fromJson(
      data as Map<String, dynamic>,
      MapEventSummaryModel.fromJson,
    );
  }

  Future<MapEventPageModel<MapEventAttendeeModel>> getAttendees(
    String eventId, {
    String? status,
    String? cursor,
    int size = 20,
  }) async {
    final data = await http.get(
      '/map-events/$eventId/attendees',
      queryParameters: {'status': ?status, 'cursor': ?cursor, 'size': size},
    );
    return MapEventPageModel.fromJson(
      data as Map<String, dynamic>,
      MapEventAttendeeModel.fromJson,
    );
  }

  /// With no [status] the backend returns accepted **and** withdrawn rows
  /// together, so the "N approved" entry list must pass `accepted` explicitly.
  /// `pending` and `rejected` are organizer-only and 403 for anyone else.
  Future<MapEventPageModel<MapEventParticipantModel>> getCars(
    String eventId, {
    String? status,
    String? cursor,
    int size = 20,
  }) async {
    final data = await http.get(
      '/map-events/$eventId/cars',
      queryParameters: {'status': ?status, 'cursor': ?cursor, 'size': size},
    );
    return MapEventPageModel.fromJson(
      data as Map<String, dynamic>,
      MapEventParticipantModel.fromJson,
    );
  }

  /// A blank query comes back empty from the backend; callers still short-
  /// circuit it client-side rather than spend a request on it.
  Future<List<OrganizerCandidateModel>> searchOrganizers(
    String query, {
    CancelToken? cancelToken,
  }) async {
    final data = await http.get(
      '/map-events/organizers/search',
      queryParameters: {'q': query},
      cancelToken: cancelToken,
    );
    return [
      for (final e in data as List<dynamic>)
        OrganizerCandidateModel.fromJson(e as Map<String, dynamic>),
    ];
  }

  Future<List<MapEventWithdrawalRequestModel>> getWithdrawals(
    String eventId,
  ) async {
    final data = await http.get('/map-events/$eventId/withdrawals');
    return [
      for (final e in data as List<dynamic>)
        MapEventWithdrawalRequestModel.fromJson(e as Map<String, dynamic>),
    ];
  }

  // ── Event writes ─────────────────────────────────────────────────────────

  Future<MapEventModel> createEvent({
    required String categoryId,
    required String title,
    required String description,
    required String locationName,
    required double lat,
    required double lng,
    required DateTime startsAt,
    DateTime? endsAt,
    required bool requiresParticipantApproval,
    DateTime? registrationDeadline,
    int? maxParticipantCapacity,
    List<String>? rules,
  }) async {
    final data = await http.post(
      '/map-events',
      body: {
        'category_id': categoryId,
        'title': title,
        'description': description,
        'location_name': locationName,
        'lat': lat,
        'lng': lng,
        'starts_at': formatInstant(startsAt),
        'ends_at': endsAt == null ? null : formatInstant(endsAt),
        'requires_participant_approval': requiresParticipantApproval,
        'registration_deadline': registrationDeadline == null
            ? null
            : formatInstant(registrationDeadline),
        'max_participant_capacity': maxParticipantCapacity,
        'rules': rules,
      },
    );
    return MapEventModel.fromJson(data as Map<String, dynamic>);
  }

  /// Only the keys the caller actually wants changed are sent: the backend
  /// reads a null as "unchanged", so an omitted key and an explicit null mean
  /// the same thing — and building the map sparsely keeps the request honest.
  Future<MapEventModel> updateEvent(
    String eventId, {
    String? title,
    String? description,
    String? locationName,
    double? lat,
    double? lng,
    DateTime? startsAt,
    DateTime? endsAt,
    bool? requiresParticipantApproval,
    DateTime? registrationDeadline,
    int? maxParticipantCapacity,
  }) async {
    final data = await http.patch(
      '/map-events/$eventId',
      body: <String, dynamic>{
        'title': ?title,
        'description': ?description,
        'location_name': ?locationName,
        'lat': ?lat,
        'lng': ?lng,
        if (startsAt != null) 'starts_at': formatInstant(startsAt),
        if (endsAt != null) 'ends_at': formatInstant(endsAt),
        'requires_participant_approval': ?requiresParticipantApproval,
        if (registrationDeadline != null)
          'registration_deadline': formatInstant(registrationDeadline),
        'max_participant_capacity': ?maxParticipantCapacity,
      },
    );
    return MapEventModel.fromJson(data as Map<String, dynamic>);
  }

  /// Full replace. `sort_order` is assigned server-side from list position, so
  /// these are plain strings — ids and positions can't be sent.
  Future<MapEventModel> replaceRules(
    String eventId,
    List<String> rules,
  ) async {
    final data = await http.put(
      '/map-events/$eventId/rules',
      body: {'rules': rules},
    );
    return MapEventModel.fromJson(data as Map<String, dynamic>);
  }

  Future<MapEventModel> setCover(String eventId, String key) async {
    final data = await http.patch(
      '/map-events/$eventId/cover',
      body: {'key': key},
    );
    return MapEventModel.fromJson(data as Map<String, dynamic>);
  }

  Future<MapEventModel> cancelEvent(String eventId) async {
    final data = await http.post('/map-events/$eventId/cancel');
    return MapEventModel.fromJson(data as Map<String, dynamic>);
  }

  Future<MapEventModel> finishEvent(String eventId) async {
    final data = await http.post('/map-events/$eventId/finish');
    return MapEventModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteEvent(String eventId) =>
      http.delete('/map-events/$eventId');

  // ── Organizers ───────────────────────────────────────────────────────────

  /// Exactly one of [userId] / [businessId] may be set — the backend 400s on
  /// both or neither.
  Future<MapEventModel> addOrganizer(
    String eventId, {
    String? userId,
    String? businessId,
  }) async {
    final data = await http.post(
      '/map-events/$eventId/organizers',
      body: {'user_id': userId, 'business_id': businessId},
    );
    return MapEventModel.fromJson(data as Map<String, dynamic>);
  }

  Future<MapEventModel> removeOrganizer(
    String eventId,
    String organizerId,
  ) async {
    final data =
        await http.delete('/map-events/$eventId/organizers/$organizerId');
    return MapEventModel.fromJson(data as Map<String, dynamic>);
  }

  // ── Attendance & participation ───────────────────────────────────────────

  Future<MapEventModel> setAttendance(String eventId, String status) async {
    final data = await http.put(
      '/map-events/$eventId/attendance',
      body: {'status': status},
    );
    return MapEventModel.fromJson(data as Map<String, dynamic>);
  }

  Future<MapEventModel> clearAttendance(String eventId) async {
    final data = await http.delete('/map-events/$eventId/attendance');
    return MapEventModel.fromJson(data as Map<String, dynamic>);
  }

  Future<MapEventParticipantModel> registerCar(
    String eventId,
    String carId,
  ) async {
    final data = await http.post(
      '/map-events/$eventId/cars',
      body: {'car_id': carId},
    );
    return MapEventParticipantModel.fromJson(data as Map<String, dynamic>);
  }

  /// Pending registrations only — an accepted entry must use [withdraw].
  Future<void> cancelCarRegistration(String eventId, String carId) =>
      http.delete('/map-events/$eventId/cars/$carId');

  Future<MapEventParticipantModel> reviewCarRegistration(
    String eventId,
    String carId,
    String status,
  ) async {
    final data = await http.patch(
      '/map-events/$eventId/cars/$carId',
      body: {'status': status},
    );
    return MapEventParticipantModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<MapEventParticipantModel>> withdraw(
    String eventId, {
    String? note,
  }) async {
    final data = await http.post(
      '/map-events/$eventId/withdraw',
      body: {'note': note},
    );
    return [
      for (final e in data as List<dynamic>)
        MapEventParticipantModel.fromJson(e as Map<String, dynamic>),
    ];
  }

  Future<void> approveWithdrawal(String eventId, String ownerId) =>
      http.post('/map-events/$eventId/withdrawals/$ownerId/approve');

  Future<List<MapEventParticipantModel>> rejectWithdrawal(
    String eventId,
    String ownerId,
  ) async {
    final data =
        await http.post('/map-events/$eventId/withdrawals/$ownerId/reject');
    return [
      for (final e in data as List<dynamic>)
        MapEventParticipantModel.fromJson(e as Map<String, dynamic>),
    ];
  }
}
