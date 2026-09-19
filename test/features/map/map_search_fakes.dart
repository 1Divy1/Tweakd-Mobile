import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tweakd/core/error/base_failures.dart';
import 'package:tweakd/features/map/domain/entities/business_pin_entity.dart';
import 'package:tweakd/features/map/domain/entities/business_search_page.dart';
import 'package:tweakd/features/map/domain/entities/geo_position.dart';
import 'package:tweakd/features/map/domain/repositories/map_repository.dart';
import 'package:tweakd/features/map_events/domain/entities/map_event_enums.dart';
import 'package:tweakd/features/map_events/domain/entities/map_event_page.dart';
import 'package:tweakd/features/map_events/domain/entities/map_event_pin.dart';
import 'package:tweakd/features/map_events/domain/repositories/map_events_repository.dart';

const testCentre = GeoPosition(lat: 46.77, lng: 23.62);

BusinessPinEntity businessPin(String id, {bool isOpenNow = true}) =>
    BusinessPinEntity(
      id: id,
      name: 'Business $id',
      typeId: 'car_wash',
      typeLabel: 'Car wash',
      position: const GeoPosition(lat: 46.78, lng: 23.63),
      logoUrl: '',
      averageRating: 4.5,
      reviewCount: 3,
      isOpenNow: isOpenNow,
    );

MapEventPinEntity eventPin(
  String id, {
  MapEventStatus status = MapEventStatus.upcoming,
  String title = 'Sunday cars & coffee',
}) =>
    MapEventPinEntity(
      id: id,
      title: title,
      categoryId: 'car_meet',
      categoryLabel: 'Car meet',
      position: const GeoPosition(lat: 46.79, lng: 23.64),
      locationName: 'Iulius Mall parking, level 2',
      coverImageUrl: null,
      startsAt: DateTime.utc(2026, 10, 4, 9),
      endsAt: DateTime.utc(2026, 10, 4, 13),
      status: status,
      attendeesCount: 12,
      attendingCarsCount: 4,
      maxParticipantCapacity: null,
    );

/// One recorded search call, so tests can assert what was asked for.
class SearchCall {
  final String query;
  final String? cursor;
  final Set<MapEventStatus> statuses;

  SearchCall(this.query, this.cursor, [this.statuses = const {}]);
}

/// Answers `searchBusinesses` from a queue of completers the test resolves,
/// so it controls exactly when (and in which order) responses land.
class FakeMapRepository implements MapRepository {
  final calls = <SearchCall>[];
  final pending = <Completer<Either<Failure, BusinessSearchPageEntity>>>[];

  /// When set, answered immediately instead of queueing a completer.
  Either<Failure, BusinessSearchPageEntity>? autoAnswer;

  @override
  Future<Either<Failure, BusinessSearchPageEntity>> searchBusinesses({
    required String query,
    required GeoPosition centre,
    String? cursor,
    int? size,
    CancelToken? cancelToken,
  }) {
    calls.add(SearchCall(query, cursor));
    final auto = autoAnswer;
    if (auto != null) return Future.value(auto);
    final completer = Completer<Either<Failure, BusinessSearchPageEntity>>();
    pending.add(completer);
    return completer.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakeEventsRepository implements MapEventsRepository {
  final calls = <SearchCall>[];
  final pending =
      <Completer<Either<Failure, MapEventPageEntity<MapEventPinEntity>>>>[];

  Either<Failure, MapEventPageEntity<MapEventPinEntity>>? autoAnswer;

  @override
  Future<Either<Failure, MapEventPageEntity<MapEventPinEntity>>> searchEvents({
    required String query,
    required GeoPosition centre,
    Set<MapEventStatus> statuses = const {},
    String? cursor,
    int? size,
    CancelToken? cancelToken,
  }) {
    calls.add(SearchCall(query, cursor, statuses));
    final auto = autoAnswer;
    if (auto != null) return Future.value(auto);
    final completer =
        Completer<Either<Failure, MapEventPageEntity<MapEventPinEntity>>>();
    pending.add(completer);
    return completer.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
