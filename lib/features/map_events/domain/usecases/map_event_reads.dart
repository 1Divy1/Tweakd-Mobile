import 'package:tweakd/core/error/base_failures.dart';
import 'package:tweakd/core/usecases/usecase.dart';
import 'package:tweakd/features/map/domain/entities/geo_position.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../entities/geocode_candidate.dart';
import '../entities/map_event.dart';
import '../entities/map_event_attendee.dart';
import '../entities/map_event_category.dart';
import '../entities/map_event_enums.dart';
import '../entities/map_event_page.dart';
import '../entities/map_event_participant.dart';
import '../entities/map_event_pin.dart';
import '../entities/map_event_summary.dart';
import '../repositories/map_events_repository.dart';

// ── Nearby pins ────────────────────────────────────────────────────────────

class GetNearbyMapEventsParams {
  final GeoPosition centre;
  final double radiusKm;
  final String? categoryId;
  final int? limit;
  final CancelToken? cancelToken;

  const GetNearbyMapEventsParams({
    required this.centre,
    required this.radiusKm,
    this.categoryId,
    this.limit,
    this.cancelToken,
  });
}

@lazySingleton
class GetNearbyMapEventsUseCase
    implements UseCase<List<MapEventPinEntity>, GetNearbyMapEventsParams> {
  final MapEventsRepository repository;

  GetNearbyMapEventsUseCase(this.repository);

  @override
  Future<Either<Failure, List<MapEventPinEntity>>> call(
    GetNearbyMapEventsParams params,
  ) {
    return repository.getNearbyEvents(
      centre: params.centre,
      radiusKm: params.radiusKm,
      categoryId: params.categoryId,
      limit: params.limit,
      cancelToken: params.cancelToken,
    );
  }
}

// ── Categories ─────────────────────────────────────────────────────────────

@lazySingleton
class GetMapEventCategoriesUseCase
    implements UseCase<List<MapEventCategoryEntity>, NoParams> {
  final MapEventsRepository repository;

  GetMapEventCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<MapEventCategoryEntity>>> call(NoParams params) {
    return repository.getCategories();
  }
}

// ── One event ──────────────────────────────────────────────────────────────

class GetMapEventParams {
  final String eventId;
  final CancelToken? cancelToken;

  const GetMapEventParams({required this.eventId, this.cancelToken});
}

@lazySingleton
class GetMapEventUseCase implements UseCase<MapEventEntity, GetMapEventParams> {
  final MapEventsRepository repository;

  GetMapEventUseCase(this.repository);

  @override
  Future<Either<Failure, MapEventEntity>> call(GetMapEventParams params) {
    return repository.getEvent(params.eventId, cancelToken: params.cancelToken);
  }
}

// ── My events ──────────────────────────────────────────────────────────────

class GetMyMapEventsParams {
  final String? cursor;
  final int size;

  const GetMyMapEventsParams({this.cursor, this.size = 20});
}

@lazySingleton
class GetMyMapEventsUseCase
    implements
        UseCase<MapEventPageEntity<MapEventSummaryEntity>,
            GetMyMapEventsParams> {
  final MapEventsRepository repository;

  GetMyMapEventsUseCase(this.repository);

  @override
  Future<Either<Failure, MapEventPageEntity<MapEventSummaryEntity>>> call(
    GetMyMapEventsParams params,
  ) {
    return repository.getMyEvents(cursor: params.cursor, size: params.size);
  }
}

// ── Attendees ──────────────────────────────────────────────────────────────

class GetMapEventAttendeesParams {
  final String eventId;
  final MapEventAttendance? status;
  final String? cursor;
  final int size;

  const GetMapEventAttendeesParams({
    required this.eventId,
    this.status,
    this.cursor,
    this.size = 20,
  });
}

@lazySingleton
class GetMapEventAttendeesUseCase
    implements
        UseCase<MapEventPageEntity<MapEventAttendeeEntity>,
            GetMapEventAttendeesParams> {
  final MapEventsRepository repository;

  GetMapEventAttendeesUseCase(this.repository);

  @override
  Future<Either<Failure, MapEventPageEntity<MapEventAttendeeEntity>>> call(
    GetMapEventAttendeesParams params,
  ) {
    return repository.getAttendees(
      params.eventId,
      status: params.status,
      cursor: params.cursor,
      size: params.size,
    );
  }
}

// ── Entry list ─────────────────────────────────────────────────────────────

class GetMapEventCarsParams {
  final String eventId;

  /// Always pass one explicitly for the public entry list
  /// ([MapEventParticipation.accepted]) — the unfiltered default mixes in
  /// withdrawn rows.
  final MapEventParticipation? status;
  final String? cursor;
  final int size;

  const GetMapEventCarsParams({
    required this.eventId,
    this.status,
    this.cursor,
    this.size = 20,
  });
}

@lazySingleton
class GetMapEventCarsUseCase
    implements
        UseCase<MapEventPageEntity<MapEventParticipantEntity>,
            GetMapEventCarsParams> {
  final MapEventsRepository repository;

  GetMapEventCarsUseCase(this.repository);

  @override
  Future<Either<Failure, MapEventPageEntity<MapEventParticipantEntity>>> call(
    GetMapEventCarsParams params,
  ) {
    return repository.getCars(
      params.eventId,
      status: params.status,
      cursor: params.cursor,
      size: params.size,
    );
  }
}

// ── The viewer's own entries ───────────────────────────────────────────────

class GetMyMapEventCarsParams {
  final String eventId;
  final CancelToken? cancelToken;

  const GetMyMapEventCarsParams({required this.eventId, this.cancelToken});
}

/// `GET /{id}/cars/mine` — every car the caller entered, whatever its status,
/// with a `rejection_reason` on the declined ones. Unpaginated: nobody enters
/// enough cars in one event for a cursor to earn its keep.
@lazySingleton
class GetMyMapEventCarsUseCase
    implements
        UseCase<List<MapEventParticipantEntity>, GetMyMapEventCarsParams> {
  final MapEventsRepository repository;

  GetMyMapEventCarsUseCase(this.repository);

  @override
  Future<Either<Failure, List<MapEventParticipantEntity>>> call(
    GetMyMapEventCarsParams params,
  ) {
    return repository.getMyCars(
      params.eventId,
      cancelToken: params.cancelToken,
    );
  }
}

// ── Location search ────────────────────────────────────────────────────────

class SearchMapEventLocationParams {
  final String city;
  final String street;
  final String addressNumber;
  final CancelToken? cancelToken;

  const SearchMapEventLocationParams({
    required this.city,
    required this.street,
    required this.addressNumber,
    this.cancelToken,
  });
}

/// `GET /map-events/geocode` — a structured address to up to five candidate
/// coordinates, for the "set location on map" picker.
///
/// The candidates only aim the camera. What the event is created with is the
/// coordinate the user taps onto the map afterwards, which is why none of
/// this is written anywhere.
@lazySingleton
class SearchMapEventLocationUseCase
    implements
        UseCase<List<GeocodeCandidateEntity>, SearchMapEventLocationParams> {
  final MapEventsRepository repository;

  SearchMapEventLocationUseCase(this.repository);

  @override
  Future<Either<Failure, List<GeocodeCandidateEntity>>> call(
    SearchMapEventLocationParams params,
  ) {
    return repository.searchLocation(
      city: params.city,
      street: params.street,
      addressNumber: params.addressNumber,
      cancelToken: params.cancelToken,
    );
  }
}
