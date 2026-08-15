import 'package:equatable/equatable.dart';

import '../../../domain/entities/map_event_summary.dart';
import '../../utils/map_event_error_mapper.dart';

sealed class MyMapEventsState extends Equatable {
  const MyMapEventsState();

  @override
  List<Object?> get props => [];
}

/// Nothing fetched yet — also the signal the profile tab uses to know it has to
/// trigger the lazy first load.
class MyMapEventsInitial extends MyMapEventsState {
  const MyMapEventsInitial();
}

class MyMapEventsLoading extends MyMapEventsState {
  const MyMapEventsLoading();
}

class MyMapEventsLoaded extends MyMapEventsState {
  final List<MapEventSummaryEntity> events;
  final String? nextCursor;
  final bool isLoadingMore;

  const MyMapEventsLoaded({
    required this.events,
    required this.nextCursor,
    this.isLoadingMore = false,
  });

  bool get hasMore => nextCursor != null;

  MyMapEventsLoaded copyWith({
    List<MapEventSummaryEntity>? events,
    String? nextCursor,
    bool clearCursor = false,
    bool? isLoadingMore,
  }) {
    return MyMapEventsLoaded(
      events: events ?? this.events,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [events, nextCursor, isLoadingMore];
}

class MyMapEventsError extends MyMapEventsState {
  final MapEventError error;

  const MyMapEventsError(this.error);

  @override
  List<Object?> get props => [error];
}
