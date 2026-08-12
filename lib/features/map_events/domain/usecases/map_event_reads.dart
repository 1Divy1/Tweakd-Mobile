import 'package:car_social_media_app/core/error/base_failures.dart';
import 'package:car_social_media_app/core/usecases/usecase.dart';
import 'package:car_social_media_app/features/map/domain/entities/geo_position.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

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
