import 'package:car_social_media_app/features/map_events/domain/usecases/map_event_reads.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/base_failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/entities/geo_position.dart';
import '../../../domain/map_defaults.dart';
import '../../../domain/usecases/get_business_detail.dart';
import '../../../domain/usecases/get_current_position.dart';
import '../../../domain/usecases/get_nearby_businesses.dart';
import '../../utils/map_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Drives the map's data: where to look, which businesses and events are near
/// there, and the profile behind a tapped business pin.
///
/// Map data is **viewport-scoped**, not cursor-paginated, so this bloc looks
/// nothing like the app's list blocs. Three rules keep it honest:
///
/// * a settled camera only triggers a fetch once it has moved
///   [kMapRefetchDistanceKm] from the last one — `onMapIdle` fires after every
///   pan and refetching on each would hammer the backend;
/// * a failed fetch never clears the pins already on screen. The page shows a
///   dismissible banner over a still-usable map instead of an error view;
/// * the two layers fail independently — a broken events endpoint must still
///   leave the businesses on the map, and vice versa.
///
/// The tapped *event* deliberately doesn't live here: its detail, RSVP and
/// participation state is `MapEventDetailBloc`'s, which the popup shares with
/// the full detail page so that logic exists once.
@injectable
class MapBloc extends Bloc<MapEvent, MapState> {
  final GetNearbyBusinessesUseCase getNearbyBusinesses;
  final GetBusinessDetailUseCase getBusinessDetail;
  final GetCurrentPositionUseCase getCurrentPosition;
  final GetNearbyMapEventsUseCase getNearbyEvents;

  /// Cancels the in-flight nearby requests when a newer one supersedes them, so
  /// a slow response for an old centre can't overwrite fresher pins.
  CancelToken? _nearbyCancelToken;

  /// Cancels the profile request when the popup closes before it lands.
  CancelToken? _detailCancelToken;

  int _cameraSeq = 0;

  MapBloc({
    required this.getNearbyBusinesses,
    required this.getBusinessDetail,
    required this.getCurrentPosition,
    required this.getNearbyEvents,
  }) : super(const MapState()) {
    on<MapStarted>(_onStarted);
    on<MapCameraSettled>(_onCameraSettled);
    on<MapBusinessSelected>(_onBusinessSelected);
    on<MapEventPinSelected>(_onEventSelected);
    on<MapBusinessDismissed>(_onBusinessDismissed);
    on<MapBusinessDetailRetried>(_onDetailRetried);
    on<MapEventPinRefreshed>(_onEventPinRefreshed);
    on<MapRecentreRequested>(_onRecentreRequested);
    on<MapErrorDismissed>(_onErrorDismissed);
  }

  Future<void> _onStarted(MapStarted event, Emitter<MapState> emit) async {
    if (state.status != MapStatus.initial) return;

    emit(state.copyWith(status: MapStatus.loading, clearError: true));

    final located = await getCurrentPosition(NoParams());
    final centre = located.fold((_) => kMapFallbackCentre, (p) => p);
    final hasFix = located.isRight();

    emit(state.copyWith(
      hasDeviceLocation: hasFix,
      cameraCommand: _command(centre),
    ));

    await _fetchAround(centre, emit);
  }

  Future<void> _onCameraSettled(
    MapCameraSettled event,
    Emitter<MapState> emit,
  ) async {
    // The very first fetch is MapStarted's job — ignore idle events until it
    // has established a centre, or the two would race.
    if (state.status == MapStatus.initial ||
        state.status == MapStatus.loading) {
      return;
    }

    // No centre means the first fetch failed; retry on the next pan rather
    // than leaving the map permanently empty.
    final last = state.fetchCentre;
    if (last != null && last.distanceKmTo(event.centre) < kMapRefetchDistanceKm) {
      return;
    }

    await _fetchAround(event.centre, emit);
  }

  Future<void> _onRecentreRequested(
    MapRecentreRequested event,
    Emitter<MapState> emit,
  ) async {
    final located = await getCurrentPosition(NoParams());

    await located.fold(
      (failure) async {
        // Here the user asked for their location explicitly, so a refusal is
        // worth saying out loud — unlike the silent fallback on first load.
        emit(state.copyWith(
          hasDeviceLocation: false,
          errorCode: MapErrorMapper.getCode(failure),
        ));
      },
      (position) async {
        emit(state.copyWith(
          hasDeviceLocation: true,
          cameraCommand: _command(position),
          clearError: true,
        ));
        await _fetchAround(position, emit);
      },
    );
  }

  Future<void> _onBusinessSelected(
    MapBusinessSelected event,
    Emitter<MapState> emit,
  ) async {
    _detailCancelToken?.cancel();
    final cancelToken = CancelToken();
    _detailCancelToken = cancelToken;

    // clearSelection first so an open event popup closes: one card at a time.
    emit(state.copyWith(clearSelection: true).copyWith(
      selectedBusinessId: event.businessId,
      detailStatus: BusinessDetailStatus.loading,
      clearDetail: true,
    ));

    await _fetchDetail(event.businessId, cancelToken, emit);
  }

  void _onEventSelected(MapEventPinSelected event, Emitter<MapState> emit) {
    // An event popup replaces a business one, so the in-flight business fetch
    // is no longer wanted.
    _detailCancelToken?.cancel();
    _detailCancelToken = null;

    emit(state
        .copyWith(clearSelection: true)
        .copyWith(selectedEventId: event.eventId));
  }

  /// Keeps a pin's counters in step with what the popup did, without spending a
  /// `/nearby` round trip on a change we already know the answer to.
  void _onEventPinRefreshed(
    MapEventPinRefreshed event,
    Emitter<MapState> emit,
  ) {
    var changed = false;
    final events = [
      for (final e in state.events)
        if (e.id == event.eventId)
          () {
            changed = true;
            return e.copyWith(
              attendeesCount: event.attendeesCount,
              attendingCarsCount: event.attendingCarsCount,
            );
          }()
        else
          e,
    ];
    if (changed) emit(state.copyWith(events: events));
  }

  Future<void> _onDetailRetried(
    MapBusinessDetailRetried event,
    Emitter<MapState> emit,
  ) async {
    final id = state.selectedBusinessId;
    if (id == null || state.detailStatus == BusinessDetailStatus.loading) return;

    _detailCancelToken?.cancel();
    final cancelToken = CancelToken();
    _detailCancelToken = cancelToken;

    emit(state.copyWith(
      detailStatus: BusinessDetailStatus.loading,
      clearDetail: true,
    ));

    await _fetchDetail(id, cancelToken, emit);
  }

  void _onBusinessDismissed(
    MapBusinessDismissed event,
    Emitter<MapState> emit,
  ) {
    _detailCancelToken?.cancel();
    _detailCancelToken = null;
    emit(state.copyWith(clearSelection: true));
  }

  void _onErrorDismissed(MapErrorDismissed event, Emitter<MapState> emit) {
    emit(state.copyWith(clearError: true));
  }

  /// Loads both layers around [centre] in one pass.
  ///
  /// The two requests go out together and are folded independently: whichever
  /// succeeds updates its pins, and only a failure of *both* raises the banner.
  /// One dead endpoint emptying the other's layer would look like "there's
  /// nothing here" rather than "something broke".
  Future<void> _fetchAround(GeoPosition centre, Emitter<MapState> emit) async {
    _nearbyCancelToken?.cancel();
    final cancelToken = CancelToken();
    _nearbyCancelToken = cancelToken;

    emit(state.copyWith(status: MapStatus.loading, clearError: true));

    // Both futures are started before either is awaited, so the two requests
    // overlap instead of running back to back.
    final businessRequest = getNearbyBusinesses(
      GetNearbyBusinessesParams(
        centre: centre,
        radiusKm: kMapSearchRadiusKm,
        limit: kMapSearchLimit,
        cancelToken: cancelToken,
      ),
    );
    final eventRequest = getNearbyEvents(
      GetNearbyMapEventsParams(
        centre: centre,
        radiusKm: kMapSearchRadiusKm,
        limit: kMapSearchLimit,
        cancelToken: cancelToken,
      ),
    );

    final businessResult = await businessRequest;
    final eventResult = await eventRequest;

    if (cancelToken != _nearbyCancelToken) return;

    // A superseded request isn't a failure the user should hear about, so it
    // counts as neither a success nor a reason to raise the banner.
    Failure? reportable(Either<Failure, Object> result) => result.fold(
          (f) => f is RequestCancelledFailure ? null : f,
          (_) => null,
        );

    final businessFailure = reportable(businessResult);
    final eventFailure = reportable(eventResult);

    // Both layers down: that's worth a banner. One of them down just leaves
    // that layer's previous pins in place — an empty map would read as "there's
    // nothing here" rather than "something broke".
    if (businessFailure != null && eventFailure != null) {
      emit(state.copyWith(
        status: MapStatus.failure,
        errorCode: MapErrorMapper.getCode(businessFailure),
      ));
      return;
    }

    emit(state.copyWith(
      status: MapStatus.loaded,
      businesses: businessResult.getOrElse(() => state.businesses),
      events: eventResult.getOrElse(() => state.events),
      fetchCentre: centre,
      clearError: true,
    ));
  }

  Future<void> _fetchDetail(
    String id,
    CancelToken cancelToken,
    Emitter<MapState> emit,
  ) async {
    final result = await getBusinessDetail(
      GetBusinessDetailParams(id: id, cancelToken: cancelToken),
    );

    // The popup may have closed, or another pin been tapped, while this was in
    // flight — either way this answer is stale.
    if (cancelToken != _detailCancelToken || state.selectedBusinessId != id) {
      return;
    }

    result.fold(
      (failure) {
        if (failure is RequestCancelledFailure) return;
        emit(state.copyWith(
          detailStatus: BusinessDetailStatus.failure,
          detailErrorCode: MapErrorMapper.getCode(failure),
        ));
      },
      (business) => emit(state.copyWith(
        detailStatus: BusinessDetailStatus.loaded,
        selectedBusiness: business,
      )),
    );
  }

  MapCameraCommand _command(GeoPosition target) =>
      MapCameraCommand(target: target, seq: ++_cameraSeq);

  @override
  Future<void> close() {
    _nearbyCancelToken?.cancel();
    _detailCancelToken?.cancel();
    return super.close();
  }
}
