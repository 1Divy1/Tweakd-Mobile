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

/// Drives the map's data: where to look, which businesses are near there, and
/// the profile behind a tapped pin.
///
/// Map data is **viewport-scoped**, not cursor-paginated, so this bloc looks
/// nothing like the app's list blocs. Two rules keep it honest:
///
/// * a settled camera only triggers a fetch once it has moved
///   [kMapRefetchDistanceKm] from the last one — `onMapIdle` fires after every
///   pan and refetching on each would hammer the backend;
/// * a failed fetch never clears the pins already on screen. The page shows a
///   dismissible banner over a still-usable map instead of an error view.
@injectable
class MapBloc extends Bloc<MapEvent, MapState> {
  final GetNearbyBusinessesUseCase getNearbyBusinesses;
  final GetBusinessDetailUseCase getBusinessDetail;
  final GetCurrentPositionUseCase getCurrentPosition;

  /// Cancels the in-flight nearby request when a newer one supersedes it, so a
  /// slow response for an old centre can't overwrite fresher pins.
  CancelToken? _nearbyCancelToken;

  /// Cancels the profile request when the popup closes before it lands.
  CancelToken? _detailCancelToken;

  int _cameraSeq = 0;

  MapBloc({
    required this.getNearbyBusinesses,
    required this.getBusinessDetail,
    required this.getCurrentPosition,
  }) : super(const MapState()) {
    on<MapStarted>(_onStarted);
    on<MapCameraSettled>(_onCameraSettled);
    on<MapBusinessSelected>(_onBusinessSelected);
    on<MapBusinessDismissed>(_onBusinessDismissed);
    on<MapBusinessDetailRetried>(_onDetailRetried);
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

    emit(state.copyWith(
      selectedBusinessId: event.businessId,
      detailStatus: BusinessDetailStatus.loading,
      clearDetail: true,
    ));

    await _fetchDetail(event.businessId, cancelToken, emit);
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

  Future<void> _fetchAround(GeoPosition centre, Emitter<MapState> emit) async {
    _nearbyCancelToken?.cancel();
    final cancelToken = CancelToken();
    _nearbyCancelToken = cancelToken;

    emit(state.copyWith(status: MapStatus.loading, clearError: true));

    final result = await getNearbyBusinesses(
      GetNearbyBusinessesParams(
        centre: centre,
        radiusKm: kMapSearchRadiusKm,
        limit: kMapSearchLimit,
        cancelToken: cancelToken,
      ),
    );

    if (cancelToken != _nearbyCancelToken) return;

    result.fold(
      (failure) {
        // A superseded request isn't a failure the user should hear about.
        if (failure is RequestCancelledFailure) return;
        emit(state.copyWith(
          status: MapStatus.failure,
          errorCode: MapErrorMapper.getCode(failure),
        ));
      },
      (businesses) => emit(state.copyWith(
        status: MapStatus.loaded,
        businesses: businesses,
        fetchCentre: centre,
        clearError: true,
      )),
    );
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
