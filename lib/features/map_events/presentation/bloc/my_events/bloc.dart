import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/map_event_reads.dart';
import '../../utils/map_event_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// "Events" on the user's own profile — `GET /map-events/mine`.
///
/// This is the only list that shows events which aren't on the map yet: their
/// `approval_status` and rejection reason are the point of it, since a creator
/// otherwise has no way to learn what happened to a submission.
@injectable
class MyMapEventsBloc extends Bloc<MyMapEventsEvent, MyMapEventsState> {
  final GetMyMapEventsUseCase getMyEvents;

  static const _pageSize = 20;

  MyMapEventsBloc({required this.getMyEvents})
      : super(const MyMapEventsInitial()) {
    on<LoadMyMapEvents>(_onLoad);
    on<RefreshMyMapEvents>(_onRefresh);
    on<LoadMoreMyMapEvents>(_onLoadMore);
  }

  Future<void> _onLoad(
    LoadMyMapEvents event,
    Emitter<MyMapEventsState> emit,
  ) async {
    emit(const MyMapEventsLoading());
    final result = await getMyEvents(
      const GetMyMapEventsParams(size: _pageSize),
    );
    result.fold(
      (failure) => emit(MyMapEventsError(MapEventErrorMapper.from(failure))),
      (page) => emit(
        MyMapEventsLoaded(events: page.items, nextCursor: page.nextCursor),
      ),
    );
  }

  Future<void> _onRefresh(
    RefreshMyMapEvents event,
    Emitter<MyMapEventsState> emit,
  ) async {
    final current = state;
    final result = await getMyEvents(
      const GetMyMapEventsParams(size: _pageSize),
    );
    result.fold(
      (failure) {
        // A failed refresh shouldn't blow away what's already on screen.
        if (current is! MyMapEventsLoaded) {
          emit(MyMapEventsError(MapEventErrorMapper.from(failure)));
        }
      },
      (page) => emit(
        MyMapEventsLoaded(events: page.items, nextCursor: page.nextCursor),
      ),
    );
  }

  Future<void> _onLoadMore(
    LoadMoreMyMapEvents event,
    Emitter<MyMapEventsState> emit,
  ) async {
    final current = state;
    if (current is! MyMapEventsLoaded ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));

    final result = await getMyEvents(
      GetMyMapEventsParams(cursor: current.nextCursor, size: _pageSize),
    );

    result.fold(
      (_) => emit(current.copyWith(isLoadingMore: false)),
      (page) => emit(
        MyMapEventsLoaded(
          events: [...current.events, ...page.items],
          nextCursor: page.nextCursor,
        ),
      ),
    );
  }
}
