import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/core/error/base_failures.dart';
import 'package:tweakd/features/map/domain/entities/business_detail_entity.dart';
import 'package:tweakd/features/map/domain/map_defaults.dart';
import 'package:tweakd/features/map/domain/usecases/get_business_detail.dart';
import 'package:tweakd/features/map/domain/usecases/get_current_position.dart';
import 'package:tweakd/features/map/domain/usecases/get_nearby_businesses.dart';
import 'package:tweakd/features/map/presentation/bloc/map/bloc.dart';
import 'package:tweakd/features/map/presentation/bloc/map/event.dart';
import 'package:tweakd/features/map/presentation/bloc/map/state.dart';
import 'package:tweakd/features/map_events/domain/entities/map_event_enums.dart';
import 'package:tweakd/features/map_events/domain/usecases/map_event_reads.dart';

import 'map_search_fakes.dart';

/// Detail fetches never resolve: these tests are about selection and the
/// temporary pin, not the business profile.
class _MapRepo extends FakeMapRepository {
  @override
  Future<Either<Failure, BusinessDetailEntity>> getBusinessDetail(
    String id, {
    CancelToken? cancelToken,
  }) =>
      Completer<Either<Failure, BusinessDetailEntity>>().future;
}

/// What happens on the map once a search result comes back: it flies there,
/// opens the popup, and — because the result may be outside the loaded ring,
/// or a past event the nearby query never returns — draws a temporary pin
/// that lives exactly as long as the selection.
void main() {
  late MapBloc bloc;

  setUp(() {
    final repo = _MapRepo();
    final events = FakeEventsRepository();
    bloc = MapBloc(
      getNearbyBusinesses: GetNearbyBusinessesUseCase(repo),
      getBusinessDetail: GetBusinessDetailUseCase(repo),
      getCurrentPosition: GetCurrentPositionUseCase(repo),
      getNearbyEvents: GetNearbyMapEventsUseCase(events),
    );
  });

  tearDown(() => bloc.close());

  Future<void> settle() async {
    for (var i = 0; i < 3; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  test('a past event gets a temporary pin, the popup and a close-in camera', () async {
    final past = eventPin('past-1', status: MapEventStatus.previous);

    bloc.add(MapSearchEventChosen(past));
    await settle();

    final state = bloc.state;
    expect(state.selectedEventId, 'past-1');
    expect(state.visibleEvents.map((e) => e.id), ['past-1']);
    expect(state.selectedEventPin, past);
    expect(state.cameraCommand?.target, past.position);
    expect(state.cameraCommand?.zoom, kMapSearchResultZoom);
  });

  test('dismissing the popup removes the temporary pin', () async {
    bloc.add(MapSearchEventChosen(eventPin('past-1', status: MapEventStatus.previous)));
    await settle();

    bloc.add(const MapBusinessDismissed());
    await settle();

    expect(bloc.state.selectedEventId, isNull);
    expect(bloc.state.searchEvent, isNull);
    expect(bloc.state.visibleEvents, isEmpty);
  });

  test('choosing a business drops a previously chosen event pin', () async {
    bloc.add(MapSearchEventChosen(eventPin('e1')));
    await settle();

    bloc.add(MapSearchBusinessChosen(businessPin('b1')));
    await settle();

    final state = bloc.state;
    expect(state.selectedEventId, isNull);
    expect(state.searchEvent, isNull);
    expect(state.selectedBusinessId, 'b1');
    expect(state.visibleBusinesses.map((b) => b.id), ['b1']);
    expect(state.selectedPin?.id, 'b1');
    expect(state.detailStatus, BusinessDetailStatus.loading);
  });

  test('tapping an ordinary pin afterwards clears the searched-for one', () async {
    bloc.add(MapSearchBusinessChosen(businessPin('b1')));
    await settle();

    bloc.add(const MapEventPinSelected('nearby-event'));
    await settle();

    expect(bloc.state.searchBusiness, isNull);
    expect(bloc.state.visibleBusinesses, isEmpty);
  });

  test('a searched-for pin the nearby fetch already has is not drawn twice', () {
    final pin = eventPin('e1');
    final state = MapState(events: [pin], searchEvent: pin);

    expect(state.visibleEvents, [pin]);
  });

  test('popup counters patch the temporary pin too', () async {
    bloc.add(MapSearchEventChosen(eventPin('past-1', status: MapEventStatus.previous)));
    await settle();

    bloc.add(const MapEventPinRefreshed(
      eventId: 'past-1',
      attendeesCount: 99,
      attendingCarsCount: 7,
    ));
    await settle();

    expect(bloc.state.searchEvent?.attendeesCount, 99);
    expect(bloc.state.selectedEventPin?.attendingCarsCount, 7);
  });
}
