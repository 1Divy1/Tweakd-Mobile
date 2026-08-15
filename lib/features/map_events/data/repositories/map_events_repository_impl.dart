import 'package:car_social_media_app/core/error/base_exceptions.dart';
import 'package:car_social_media_app/core/error/base_failures.dart';
import 'package:car_social_media_app/features/map/domain/entities/geo_position.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/geocode_candidate.dart';
import '../../domain/entities/map_event.dart';
import '../../domain/entities/map_event_attendee.dart';
import '../../domain/entities/map_event_category.dart';
import '../../domain/entities/map_event_enums.dart';
import '../../domain/entities/map_event_page.dart';
import '../../domain/entities/map_event_participant.dart';
import '../../domain/entities/map_event_pin.dart';
import '../../domain/entities/map_event_summary.dart';
import '../../domain/entities/map_event_withdrawal_request.dart';
import '../../domain/entities/organizer_candidate.dart';
import '../../domain/failures/map_event_failures.dart';
import '../../domain/repositories/map_events_repository.dart';
import '../datasources/map_event_storage_data_source.dart';
import '../datasources/map_events_api_data_source.dart';

@LazySingleton(as: MapEventsRepository)
class MapEventsRepositoryImpl implements MapEventsRepository {
  final MapEventsApiDataSource api;
  final MapEventStorageDataSource storage;

  MapEventsRepositoryImpl(this.api, this.storage);

  // ── Reads ────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<MapEventPinEntity>>> getNearbyEvents({
    required GeoPosition centre,
    required double radiusKm,
    String? categoryId,
    int? limit,
    CancelToken? cancelToken,
  }) {
    return _guard('getNearbyEvents', () async {
      final pins = await api.getNearby(
        lat: centre.lat,
        lng: centre.lng,
        radiusKm: radiusKm,
        categoryId: categoryId,
        limit: limit,
        cancelToken: cancelToken,
      );
      return [for (final p in pins) p.toEntity()];
    });
  }

  @override
  Future<Either<Failure, List<MapEventCategoryEntity>>> getCategories() {
    return _guard('getCategories', () async {
      final categories = await api.getCategories();
      return [for (final c in categories) c.toEntity()];
    });
  }

  @override
  Future<Either<Failure, MapEventEntity>> getEvent(
    String eventId, {
    CancelToken? cancelToken,
  }) {
    return _guard('getEvent', () async {
      final event = await api.getEvent(eventId, cancelToken: cancelToken);
      return event.toEntity();
    });
  }

  @override
  Future<Either<Failure, MapEventPageEntity<MapEventSummaryEntity>>> getMyEvents({
    String? cursor,
    int size = 20,
  }) {
    return _guard('getMyEvents', () async {
      final page = await api.getMyEvents(cursor: cursor, size: size);
      return page.toEntity((m) => m.toEntity());
    });
  }

  @override
  Future<Either<Failure, MapEventPageEntity<MapEventAttendeeEntity>>> getAttendees(
    String eventId, {
    MapEventAttendance? status,
    String? cursor,
    int size = 20,
  }) {
    return _guard('getAttendees', () async {
      final page = await api.getAttendees(
        eventId,
        status: status?.apiValue,
        cursor: cursor,
        size: size,
      );
      return page.toEntity((m) => m.toEntity());
    });
  }

  @override
  Future<Either<Failure, MapEventPageEntity<MapEventParticipantEntity>>> getCars(
    String eventId, {
    MapEventParticipation? status,
    String? cursor,
    int size = 20,
  }) {
    return _guard('getCars', () async {
      final page = await api.getCars(
        eventId,
        status: status?.apiValue,
        cursor: cursor,
        size: size,
      );
      return page.toEntity((m) => m.toEntity());
    });
  }

  @override
  Future<Either<Failure, List<MapEventParticipantEntity>>> getMyCars(
    String eventId, {
    CancelToken? cancelToken,
  }) {
    return _guard('getMyCars', () async {
      final rows = await api.getMyCars(eventId, cancelToken: cancelToken);
      return [for (final r in rows) r.toEntity()];
    });
  }

  @override
  Future<Either<Failure, List<OrganizerCandidateEntity>>> searchOrganizers(
    String query, {
    CancelToken? cancelToken,
  }) {
    return _guard('searchOrganizers', () async {
      final results = await api.searchOrganizers(query, cancelToken: cancelToken);
      return [for (final r in results) r.toEntity()];
    });
  }

  @override
  Future<Either<Failure, List<GeocodeCandidateEntity>>> searchLocation({
    required String city,
    required String street,
    required String addressNumber,
    CancelToken? cancelToken,
  }) {
    return _guard('searchLocation', () async {
      final results = await api.searchLocation(
        place: city,
        street: street,
        addressNumber: addressNumber,
        cancelToken: cancelToken,
      );
      return [for (final r in results) r.toEntity()];
    });
  }

  @override
  Future<Either<Failure, List<MapEventWithdrawalRequestEntity>>> getWithdrawals(
    String eventId,
  ) {
    return _guard('getWithdrawals', () async {
      final requests = await api.getWithdrawals(eventId);
      return [for (final r in requests) r.toEntity()];
    });
  }

  // ── Event writes ─────────────────────────────────────────────────────────

  @override
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
  }) {
    return _guard('createEvent', () async {
      final event = await api.createEvent(
        categoryId: categoryId,
        title: title,
        description: description,
        locationName: locationName,
        lat: position.lat,
        lng: position.lng,
        startsAt: startsAt,
        endsAt: endsAt,
        requiresParticipantApproval: requiresParticipantApproval,
        registrationDeadline: registrationDeadline,
        maxParticipantCapacity: maxParticipantCapacity,
        rules: rules,
      );
      return event.toEntity();
    });
  }

  @override
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
  }) {
    return _guard('updateEvent', () async {
      final event = await api.updateEvent(
        eventId,
        title: title,
        description: description,
        locationName: locationName,
        lat: position?.lat,
        lng: position?.lng,
        startsAt: startsAt,
        endsAt: endsAt,
        requiresParticipantApproval: requiresParticipantApproval,
        registrationDeadline: registrationDeadline,
        maxParticipantCapacity: maxParticipantCapacity,
      );
      return event.toEntity();
    });
  }

  @override
  Future<Either<Failure, MapEventEntity>> replaceRules(
    String eventId,
    List<String> rules,
  ) {
    return _guard('replaceRules', () async {
      final event = await api.replaceRules(eventId, rules);
      return event.toEntity();
    });
  }

  @override
  Future<Either<Failure, ({String key, String uploadUrl})>> getCoverUploadUrl(
    String eventId,
  ) {
    return _guard('getCoverUploadUrl', () async {
      final slot = await storage.getCoverUploadUrl(eventId);
      return (key: slot.key, uploadUrl: slot.uploadUrl);
    });
  }

  @override
  Future<Either<Failure, MapEventEntity>> setCover(String eventId, String key) {
    return _guard('setCover', () async {
      final event = await api.setCover(eventId, key);
      return event.toEntity();
    });
  }

  @override
  Future<Either<Failure, MapEventEntity>> cancelEvent(String eventId) {
    return _guard('cancelEvent', () async {
      final event = await api.cancelEvent(eventId);
      return event.toEntity();
    });
  }

  @override
  Future<Either<Failure, MapEventEntity>> finishEvent(String eventId) {
    return _guard('finishEvent', () async {
      final event = await api.finishEvent(eventId);
      return event.toEntity();
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteEvent(String eventId) {
    return _guard('deleteEvent', () async {
      await api.deleteEvent(eventId);
      return unit;
    });
  }

  // ── Organizers ───────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, MapEventEntity>> addOrganizer(
    String eventId, {
    String? userId,
    String? businessId,
  }) {
    return _guard('addOrganizer', () async {
      final event = await api.addOrganizer(
        eventId,
        userId: userId,
        businessId: businessId,
      );
      return event.toEntity();
    });
  }

  @override
  Future<Either<Failure, MapEventEntity>> removeOrganizer(
    String eventId,
    String organizerId,
  ) {
    return _guard('removeOrganizer', () async {
      final event = await api.removeOrganizer(eventId, organizerId);
      return event.toEntity();
    });
  }

  // ── Attendance & participation ───────────────────────────────────────────

  @override
  Future<Either<Failure, MapEventEntity>> setAttendance(
    String eventId,
    MapEventAttendance status,
  ) {
    return _guard('setAttendance', () async {
      final event = await api.setAttendance(eventId, status.apiValue);
      return event.toEntity();
    });
  }

  @override
  Future<Either<Failure, MapEventEntity>> clearAttendance(String eventId) {
    return _guard('clearAttendance', () async {
      final event = await api.clearAttendance(eventId);
      return event.toEntity();
    });
  }

  @override
  Future<Either<Failure, MapEventEntity>> registerCar(
    String eventId,
    String carId,
  ) {
    return _guard('registerCar', () async {
      final event = await api.registerCar(eventId, carId);
      return event.toEntity();
    });
  }

  @override
  Future<Either<Failure, MapEventEntity>> cancelCarRegistration(
    String eventId,
    String carId,
  ) {
    return _guard('cancelCarRegistration', () async {
      final event = await api.cancelCarRegistration(eventId, carId);
      return event.toEntity();
    });
  }

  @override
  Future<Either<Failure, MapEventEntity>> reviewCarRegistration(
    String eventId,
    String carId,
    MapEventParticipation status, {
    String? reason,
  }) {
    return _guard('reviewCarRegistration', () async {
      final event = await api.reviewCarRegistration(
        eventId,
        carId,
        status.apiValue,
        reason: reason,
      );
      return event.toEntity();
    });
  }

  @override
  Future<Either<Failure, MapEventEntity>> withdraw(
    String eventId, {
    String? note,
  }) {
    return _guard('withdraw', () async {
      final event = await api.withdraw(eventId, note: note);
      return event.toEntity();
    });
  }

  @override
  Future<Either<Failure, MapEventEntity>> approveWithdrawal(
    String eventId,
    String ownerId,
  ) {
    return _guard('approveWithdrawal', () async {
      final event = await api.approveWithdrawal(eventId, ownerId);
      return event.toEntity();
    });
  }

  @override
  Future<Either<Failure, MapEventEntity>> rejectWithdrawal(
    String eventId,
    String ownerId,
  ) {
    return _guard('rejectWithdrawal', () async {
      final event = await api.rejectWithdrawal(eventId, ownerId);
      return event.toEntity();
    });
  }

  // ── Error pipeline ───────────────────────────────────────────────────────

  /// Every method funnels through here so the exception → [Failure] mapping is
  /// written once. Twenty-six copies of the same `try/catch` ladder would drift
  /// apart the first time a case is added.
  ///
  /// The interesting cases:
  /// * **409** is always a participation conflict — the event finished, the
  ///   registration deadline passed, or the entry list is full. The backend
  ///   only tells those apart in prose, so the server's message is carried
  ///   through verbatim for the UI to show.
  /// * **403** means "you aren't an organizer here", which several endpoints
  ///   raise for reads too (pending/rejected car lists, the withdrawal queue).
  /// * **400** is user-fixable input — a missing deadline, an over-long rule,
  ///   an organizer who already organizes the event.
  Future<Either<Failure, T>> _guard<T>(
    String operation,
    Future<T> Function() action,
  ) async {
    try {
      return Right(await action());
    } on RequestCancelledException {
      return const Left(RequestCancelledFailure());
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on ConflictException catch (e) {
      return Left(
        MapEventParticipationConflictFailure(e.message, errorCode: e.errorCode),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      return Left(switch (e.statusCode) {
        404 => MapEventNotFoundFailure(e.message),
        403 => MapEventForbiddenFailure(e.message),
        400 || 422 => MapEventInvalidInputFailure(e.message),
        _ => ServerFailure(e.message),
      });
    } catch (e) {
      debugPrint('Unexpected error in MapEventsRepository.$operation: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }
}
