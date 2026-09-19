import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/core/error/base_failures.dart';
import 'package:tweakd/features/map/domain/entities/business_search_page.dart';
import 'package:tweakd/features/map/domain/usecases/search_businesses.dart';
import 'package:tweakd/features/map/presentation/bloc/map_search/bloc.dart';
import 'package:tweakd/features/map/presentation/bloc/map_search/event.dart';
import 'package:tweakd/features/map/presentation/bloc/map_search/state.dart';
import 'package:tweakd/features/map/presentation/utils/map_error_mapper.dart';
import 'package:tweakd/features/map_events/domain/entities/map_event_enums.dart';
import 'package:tweakd/features/map_events/domain/entities/map_event_page.dart';
import 'package:tweakd/features/map_events/domain/entities/map_event_pin.dart';
import 'package:tweakd/features/map_events/domain/usecases/map_event_reads.dart';

import 'map_search_fakes.dart';

/// The map search screen's state machine: debounced querying of two
/// independently paged lists, the phase chips, and — the part most likely to
/// regress quietly — dropping answers that arrive after the question changed.
void main() {
  late FakeEventsRepository events;
  late FakeMapRepository businesses;
  late MapSearchBloc bloc;

  setUp(() {
    events = FakeEventsRepository();
    businesses = FakeMapRepository();
    bloc = MapSearchBloc(
      searchEvents: SearchMapEventsUseCase(events),
      searchBusinesses: SearchBusinessesUseCase(businesses),
      centre: testCentre,
    );
  });

  tearDown(() => bloc.close());

  Future<void> settle() async {
    for (var i = 0; i < 5; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  /// Longer than the bloc's 300 ms debounce.
  Future<void> debounce() => Future<void>.delayed(const Duration(milliseconds: 350));

  Either<Failure, MapEventPageEntity<MapEventPinEntity>> eventPage(
    List<String> ids, {
    String? next,
    MapEventStatus status = MapEventStatus.upcoming,
  }) =>
      Right(MapEventPageEntity(
        items: [for (final id in ids) eventPin(id, status: status)],
        nextCursor: next,
      ));

  Either<Failure, BusinessSearchPageEntity> businessPage(
    List<String> ids, {
    String? next,
  }) =>
      Right(BusinessSearchPageEntity(
        items: [for (final id in ids) businessPin(id)],
        nextCursor: next,
      ));

  Future<void> search(String query) async {
    bloc.add(MapSearchQueryChanged(query));
    await debounce();
    await settle();
  }

  test('a query shorter than two characters never reaches the backend', () async {
    await search(' c ');

    expect(events.calls, isEmpty);
    expect(businesses.calls, isEmpty);
    expect(bloc.state.hasQuery, isFalse);
  });

  test('typing is debounced into one search of each kind, trimmed', () async {
    bloc.add(const MapSearchQueryChanged('ca'));
    bloc.add(const MapSearchQueryChanged('car'));
    bloc.add(const MapSearchQueryChanged('cars '));
    await debounce();
    await settle();

    expect(events.calls.map((c) => c.query), ['cars']);
    expect(businesses.calls.map((c) => c.query), ['cars']);
    expect(bloc.state.events.status, MapSearchSectionStatus.loading);
    expect(bloc.state.businesses.status, MapSearchSectionStatus.loading);
  });

  test('events default to live + upcoming', () async {
    events.autoAnswer = eventPage([]);
    businesses.autoAnswer = businessPage([]);

    await search('meet');

    expect(events.calls.single.statuses,
        {MapEventStatus.live, MapEventStatus.upcoming});
  });

  test('each list loads and fails on its own', () async {
    await search('meet');

    events.pending.single.complete(eventPage(['e1', 'e2'], next: 'c1'));
    businesses.pending.single
        .complete(const Left(NetworkFailure('No internet connection.')));
    await settle();

    expect(bloc.state.events.status, MapSearchSectionStatus.loaded);
    expect(bloc.state.events.items.map((e) => e.id), ['e1', 'e2']);
    expect(bloc.state.events.hasMore, isTrue);
    expect(bloc.state.businesses.status, MapSearchSectionStatus.failure);
    expect(bloc.state.businesses.errorCode, MapErrorCode.network);
  });

  test('a later page is appended with the cursor from the one before', () async {
    await search('meet');
    events.pending.single.complete(eventPage(['e1'], next: 'c1'));
    businesses.pending.single.complete(businessPage([]));
    await settle();

    bloc.add(const MapSearchMoreRequested(MapSearchKind.events));
    // A second request while the first is in flight must not double-fetch.
    bloc.add(const MapSearchMoreRequested(MapSearchKind.events));
    await settle();

    expect(events.calls.length, 2);
    expect(events.calls.last.cursor, 'c1');
    expect(bloc.state.events.isLoadingMore, isTrue);

    events.pending.last.complete(eventPage(['e2']));
    await settle();

    expect(bloc.state.events.items.map((e) => e.id), ['e1', 'e2']);
    expect(bloc.state.events.hasMore, isFalse);
    expect(bloc.state.events.isLoadingMore, isFalse);
  });

  test('the last page asks for nothing more', () async {
    events.autoAnswer = eventPage(['e1']);
    businesses.autoAnswer = businessPage([]);
    await search('meet');

    bloc.add(const MapSearchMoreRequested(MapSearchKind.events));
    await settle();

    expect(events.calls.length, 1);
  });

  test('a failed later page keeps the list and retries only that page', () async {
    await search('meet');
    events.pending.single.complete(eventPage(['e1'], next: 'c1'));
    businesses.pending.single.complete(businessPage([]));
    await settle();

    bloc.add(const MapSearchMoreRequested(MapSearchKind.events));
    await settle();
    events.pending.last.complete(const Left(ServerFailure('boom')));
    await settle();

    expect(bloc.state.events.status, MapSearchSectionStatus.loaded);
    expect(bloc.state.events.items.map((e) => e.id), ['e1']);
    expect(bloc.state.events.loadMoreFailed, isTrue);

    bloc.add(const MapSearchRetried(MapSearchKind.events));
    await settle();

    expect(events.calls.last.cursor, 'c1');
  });

  test('an answer for a query the user has moved on from is dropped', () async {
    await search('meet');
    final stale = events.pending.single;

    await search('coffee');
    events.pending.last.complete(eventPage(['fresh']));
    // The old answer lands last — it must not overwrite the new one.
    stale.complete(eventPage(['stale']));
    await settle();

    expect(bloc.state.query, 'coffee');
    expect(bloc.state.events.items.map((e) => e.id), ['fresh']);
  });

  test('toggling a chip reloads only the events, with the new phases', () async {
    events.autoAnswer = eventPage(['e1']);
    businesses.autoAnswer = businessPage(['b1']);
    await search('meet');

    bloc.add(const MapSearchStatusToggled(MapEventStatus.previous));
    await settle();

    expect(events.calls.length, 2);
    expect(events.calls.last.statuses, {
      MapEventStatus.live,
      MapEventStatus.upcoming,
      MapEventStatus.previous,
    });
    expect(businesses.calls.length, 1);
  });

  test('the last chip still on cannot be turned off', () async {
    bloc.add(const MapSearchStatusToggled(MapEventStatus.live));
    await settle();
    expect(bloc.state.statuses, {MapEventStatus.upcoming});

    bloc.add(const MapSearchStatusToggled(MapEventStatus.upcoming));
    await settle();
    expect(bloc.state.statuses, {MapEventStatus.upcoming});
  });

  test('chips changed before typing are used by the first search', () async {
    events.autoAnswer = eventPage([]);
    businesses.autoAnswer = businessPage([]);

    bloc.add(const MapSearchStatusToggled(MapEventStatus.previous));
    await settle();
    expect(events.calls, isEmpty);

    await search('meet');
    expect(events.calls.single.statuses, contains(MapEventStatus.previous));
  });

  test('clearing resets both lists and drops what was in flight', () async {
    await search('meet');
    final inFlight = events.pending.single;

    bloc.add(const MapSearchCleared());
    await settle();
    inFlight.complete(eventPage(['late']));
    await settle();

    expect(bloc.state.hasQuery, isFalse);
    expect(bloc.state.events.items, isEmpty);
    expect(bloc.state.events.status, MapSearchSectionStatus.idle);
  });
}
