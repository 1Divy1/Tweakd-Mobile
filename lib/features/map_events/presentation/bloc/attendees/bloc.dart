import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/map_event_reads.dart';
import '../../utils/map_event_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// The "see all attendees" list: one cursor-paginated page per RSVP status.
///
/// The two tabs are separate queries rather than a client-side filter, because
/// the endpoint pages per status — mixing them locally would give a list that
/// runs out at different points depending on which tab you were on.
@injectable
class MapEventAttendeesBloc
    extends Bloc<MapEventAttendeesEvent, MapEventAttendeesState> {
  final GetMapEventAttendeesUseCase getAttendees;

  static const _pageSize = 30;

  String _eventId = '';

  MapEventAttendeesBloc({required this.getAttendees})
      : super(const MapEventAttendeesState()) {
    on<LoadMapEventAttendees>(_onLoad);
    on<ChangeAttendeeFilter>(_onChangeFilter);
    on<LoadMoreMapEventAttendees>(_onLoadMore);
  }

  Future<void> _onLoad(
    LoadMapEventAttendees event,
    Emitter<MapEventAttendeesState> emit,
  ) async {
    _eventId = event.eventId;
    await _fetchFirstPage(emit);
  }

  Future<void> _onChangeFilter(
    ChangeAttendeeFilter event,
    Emitter<MapEventAttendeesState> emit,
  ) async {
    if (state.filter == event.status) return;
    emit(state.copyWith(filter: event.status));
    await _fetchFirstPage(emit);
  }

  Future<void> _fetchFirstPage(Emitter<MapEventAttendeesState> emit) async {
    emit(state.copyWith(
      status: MapEventAttendeesStatus.loading,
      attendees: const [],
      clearCursor: true,
      clearError: true,
    ));

    final result = await getAttendees(
      GetMapEventAttendeesParams(
        eventId: _eventId,
        status: state.filter,
        size: _pageSize,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: MapEventAttendeesStatus.failure,
        error: MapEventErrorMapper.from(failure),
      )),
      (page) => emit(state.copyWith(
        status: MapEventAttendeesStatus.loaded,
        attendees: page.items,
        nextCursor: page.nextCursor,
        clearCursor: page.nextCursor == null,
      )),
    );
  }

  Future<void> _onLoadMore(
    LoadMoreMapEventAttendees event,
    Emitter<MapEventAttendeesState> emit,
  ) async {
    final cursor = state.nextCursor;
    if (cursor == null || state.isLoadingMore) return;

    emit(state.copyWith(isLoadingMore: true));
    // Captured so a tab switch mid-request can't append the wrong list.
    final filter = state.filter;

    final result = await getAttendees(
      GetMapEventAttendeesParams(
        eventId: _eventId,
        status: filter,
        cursor: cursor,
        size: _pageSize,
      ),
    );

    if (state.filter != filter) return;

    result.fold(
      // A failed "load more" shouldn't blow away what's already on screen.
      (_) => emit(state.copyWith(isLoadingMore: false)),
      (page) => emit(state.copyWith(
        attendees: [...state.attendees, ...page.items],
        nextCursor: page.nextCursor,
        clearCursor: page.nextCursor == null,
        isLoadingMore: false,
      )),
    );
  }
}
