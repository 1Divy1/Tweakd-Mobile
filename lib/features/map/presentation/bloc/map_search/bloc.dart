import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tweakd/core/analytics/analytics_events.dart';
import 'package:tweakd/core/analytics/analytics_service.dart';
import 'package:tweakd/features/map_events/domain/entities/map_event_page.dart';
import 'package:tweakd/features/map_events/domain/entities/map_event_pin.dart';
import 'package:tweakd/features/map_events/domain/usecases/map_event_reads.dart';

import '../../../../../core/error/base_failures.dart';
import '../../../domain/entities/business_search_page.dart';
import '../../../domain/entities/geo_position.dart';
import '../../../domain/usecases/search_businesses.dart';
import '../../utils/map_error_mapper.dart';
import 'event.dart';
import 'state.dart';

const _debounceDuration = Duration(milliseconds: 300);
const _minQueryLength = 2;
const _pageSize = 20;

/// The map's search screen: events and businesses matching a query, each in
/// its own keyset-paged list, nearest to the map's centre first.
///
/// The two lists are independent end to end — separate requests, cancel
/// tokens, cursors and failures — because they are separate endpoints and
/// separate tabs. A settled query loads the first page of both; the phase
/// chips reload only the events.
///
/// Staleness is handled with one cancel token per list: any newer request for
/// that list (a new query, a chip change, a clear) cancels the old one, and a
/// response whose token is no longer current is dropped on arrival.
@injectable
class MapSearchBloc extends Bloc<MapSearchEvent, MapSearchState> {
  final SearchMapEventsUseCase searchEvents;
  final SearchBusinessesUseCase searchBusinesses;
  final AnalyticsService analytics;

  Timer? _debounce;
  CancelToken? _eventsToken;
  CancelToken? _businessesToken;

  MapSearchBloc({
    required this.searchEvents,
    required this.searchBusinesses,
    @factoryParam required GeoPosition centre,
    this.analytics = const NoopAnalyticsService(),
  }) : super(MapSearchState(centre: centre)) {
    on<MapSearchQueryChanged>(_onQueryChanged);
    on<MapSearchSubmitted>(_onSubmitted);
    on<MapSearchCleared>(_onCleared);
    on<MapSearchStatusToggled>(_onStatusToggled);
    on<MapSearchMoreRequested>(_onMoreRequested);
    on<MapSearchRetried>(_onRetried);
  }

  void _onQueryChanged(MapSearchQueryChanged event, Emitter<MapSearchState> emit) {
    _debounce?.cancel();
    final query = event.query.trim();

    if (query.length < _minQueryLength) {
      _reset(emit);
      return;
    }
    if (query == state.query) return;

    _debounce = Timer(_debounceDuration, () {
      if (!isClosed) add(MapSearchSubmitted(query));
    });
  }

  Future<void> _onSubmitted(
    MapSearchSubmitted event,
    Emitter<MapSearchState> emit,
  ) async {
    emit(state.copyWith(
      query: event.query,
      events: const MapSearchSection.loading(),
      businesses: const MapSearchSection.loading(),
    ));
    await Future.wait([
      _loadFirstEvents(emit),
      _loadFirstBusinesses(emit),
    ]);
  }

  void _onCleared(MapSearchCleared event, Emitter<MapSearchState> emit) {
    _debounce?.cancel();
    _reset(emit);
  }

  Future<void> _onStatusToggled(
    MapSearchStatusToggled event,
    Emitter<MapSearchState> emit,
  ) async {
    final statuses = {...state.statuses};
    if (statuses.contains(event.status)) {
      if (statuses.length == 1) return;
      statuses.remove(event.status);
    } else {
      statuses.add(event.status);
    }

    emit(state.copyWith(
      statuses: statuses,
      events: state.hasQuery ? const MapSearchSection.loading() : null,
    ));
    if (state.hasQuery) await _loadFirstEvents(emit);
  }

  Future<void> _onMoreRequested(
    MapSearchMoreRequested event,
    Emitter<MapSearchState> emit,
  ) async {
    switch (event.kind) {
      case MapSearchKind.events:
        final section = state.events;
        if (!_canLoadMore(section)) return;
        emit(state.copyWith(
          events: section.copyWith(isLoadingMore: true, loadMoreFailed: false),
        ));
        await _loadMoreEvents(emit);
      case MapSearchKind.businesses:
        final section = state.businesses;
        if (!_canLoadMore(section)) return;
        emit(state.copyWith(
          businesses:
              section.copyWith(isLoadingMore: true, loadMoreFailed: false),
        ));
        await _loadMoreBusinesses(emit);
    }
  }

  /// A failed first page reloads from scratch; a failed later page retries
  /// just that page, keeping everything already listed.
  Future<void> _onRetried(
    MapSearchRetried event,
    Emitter<MapSearchState> emit,
  ) async {
    if (!state.hasQuery) return;

    switch (event.kind) {
      case MapSearchKind.events:
        if (state.events.status == MapSearchSectionStatus.failure) {
          emit(state.copyWith(events: const MapSearchSection.loading()));
          await _loadFirstEvents(emit);
        } else if (state.events.loadMoreFailed) {
          add(const MapSearchMoreRequested(MapSearchKind.events));
        }
      case MapSearchKind.businesses:
        if (state.businesses.status == MapSearchSectionStatus.failure) {
          emit(state.copyWith(businesses: const MapSearchSection.loading()));
          await _loadFirstBusinesses(emit);
        } else if (state.businesses.loadMoreFailed) {
          add(const MapSearchMoreRequested(MapSearchKind.businesses));
        }
    }
  }

  // ── Events ───────────────────────────────────────────────────────────────

  Future<void> _loadFirstEvents(Emitter<MapSearchState> emit) async {
    final token = _renew(_eventsToken);
    _eventsToken = token;
    final query = state.query;
    final statuses = state.statuses;

    final result = await searchEvents(SearchMapEventsParams(
      query: query,
      centre: state.centre,
      statuses: statuses,
      size: _pageSize,
      cancelToken: token,
    ));
    if (token != _eventsToken) return;

    _foldFirst<MapEventPageEntity<MapEventPinEntity>>(
      result,
      onFailure: (code) => emit(state.copyWith(
        events: MapSearchSection(
          status: MapSearchSectionStatus.failure,
          errorCode: code,
        ),
      )),
      onSuccess: (page) {
        // Never the query itself: free text stays out of analytics.
        analytics.track(AnalyticsEvents.mapSearchPerformed, {
          'kind': 'event',
          'result_count': page.items.length,
          'has_more': page.hasMore,
          'statuses': ([for (final s in statuses) s.apiValue]..sort()).join(','),
        });
        emit(state.copyWith(
          events: MapSearchSection(
            status: MapSearchSectionStatus.loaded,
            items: page.items,
            nextCursor: page.nextCursor,
          ),
        ));
      },
    );
  }

  Future<void> _loadMoreEvents(Emitter<MapSearchState> emit) async {
    final token = _renew(_eventsToken);
    _eventsToken = token;

    final result = await searchEvents(SearchMapEventsParams(
      query: state.query,
      centre: state.centre,
      statuses: state.statuses,
      cursor: state.events.nextCursor,
      size: _pageSize,
      cancelToken: token,
    ));
    if (token != _eventsToken) return;

    result.fold(
      (failure) {
        if (failure is RequestCancelledFailure) return;
        emit(state.copyWith(
          events: state.events
              .copyWith(isLoadingMore: false, loadMoreFailed: true),
        ));
      },
      (page) => emit(state.copyWith(
        events: state.events.copyWith(
          items: [...state.events.items, ...page.items],
          nextCursor: page.nextCursor,
          clearCursor: page.nextCursor == null,
          isLoadingMore: false,
        ),
      )),
    );
  }

  // ── Businesses ───────────────────────────────────────────────────────────

  Future<void> _loadFirstBusinesses(Emitter<MapSearchState> emit) async {
    final token = _renew(_businessesToken);
    _businessesToken = token;

    final result = await searchBusinesses(SearchBusinessesParams(
      query: state.query,
      centre: state.centre,
      size: _pageSize,
      cancelToken: token,
    ));
    if (token != _businessesToken) return;

    _foldFirst<BusinessSearchPageEntity>(
      result,
      onFailure: (code) => emit(state.copyWith(
        businesses: MapSearchSection(
          status: MapSearchSectionStatus.failure,
          errorCode: code,
        ),
      )),
      onSuccess: (page) {
        analytics.track(AnalyticsEvents.mapSearchPerformed, {
          'kind': 'business',
          'result_count': page.items.length,
          'has_more': page.hasMore,
        });
        emit(state.copyWith(
          businesses: MapSearchSection(
            status: MapSearchSectionStatus.loaded,
            items: page.items,
            nextCursor: page.nextCursor,
          ),
        ));
      },
    );
  }

  Future<void> _loadMoreBusinesses(Emitter<MapSearchState> emit) async {
    final token = _renew(_businessesToken);
    _businessesToken = token;

    final result = await searchBusinesses(SearchBusinessesParams(
      query: state.query,
      centre: state.centre,
      cursor: state.businesses.nextCursor,
      size: _pageSize,
      cancelToken: token,
    ));
    if (token != _businessesToken) return;

    result.fold(
      (failure) {
        if (failure is RequestCancelledFailure) return;
        emit(state.copyWith(
          businesses: state.businesses
              .copyWith(isLoadingMore: false, loadMoreFailed: true),
        ));
      },
      (page) => emit(state.copyWith(
        businesses: state.businesses.copyWith(
          items: [...state.businesses.items, ...page.items],
          nextCursor: page.nextCursor,
          clearCursor: page.nextCursor == null,
          isLoadingMore: false,
        ),
      )),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  bool _canLoadMore(MapSearchSection section) =>
      section.status == MapSearchSectionStatus.loaded &&
      section.hasMore &&
      !section.isLoadingMore;

  void _foldFirst<T>(
    Either<Failure, T> result, {
    required void Function(MapErrorCode code) onFailure,
    required void Function(T page) onSuccess,
  }) {
    result.fold(
      (failure) {
        // A cancelled request was superseded; whoever cancelled it owns the
        // section now.
        if (failure is RequestCancelledFailure) return;
        onFailure(MapErrorMapper.getCode(failure));
      },
      onSuccess,
    );
  }

  /// Cancels [previous] (if still running) and hands out a fresh token.
  CancelToken _renew(CancelToken? previous) {
    if (previous != null && !previous.isCancelled) previous.cancel();
    return CancelToken();
  }

  void _reset(Emitter<MapSearchState> emit) {
    _eventsToken = _renew(_eventsToken);
    _businessesToken = _renew(_businessesToken);
    emit(state.copyWith(
      query: '',
      events: const MapSearchSection(),
      businesses: const MapSearchSection(),
    ));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    _eventsToken?.cancel();
    _businessesToken?.cancel();
    return super.close();
  }
}
