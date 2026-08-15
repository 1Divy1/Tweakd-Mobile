import 'package:equatable/equatable.dart';

import '../../../domain/entities/map_event_attendee.dart';
import '../../../domain/entities/map_event_enums.dart';
import '../../utils/map_event_error_mapper.dart';

enum MapEventAttendeesStatus { initial, loading, loaded, failure }

class MapEventAttendeesState extends Equatable {
  final MapEventAttendeesStatus status;
  final MapEventAttendance filter;
  final List<MapEventAttendeeEntity> attendees;
  final String? nextCursor;
  final bool isLoadingMore;
  final MapEventError? error;

  const MapEventAttendeesState({
    this.status = MapEventAttendeesStatus.initial,
    this.filter = MapEventAttendance.attending,
    this.attendees = const [],
    this.nextCursor,
    this.isLoadingMore = false,
    this.error,
  });

  /// A null cursor is the only end-of-list signal — never infer it from a short
  /// page.
  bool get hasMore => nextCursor != null;

  MapEventAttendeesState copyWith({
    MapEventAttendeesStatus? status,
    MapEventAttendance? filter,
    List<MapEventAttendeeEntity>? attendees,
    String? nextCursor,
    bool clearCursor = false,
    bool? isLoadingMore,
    MapEventError? error,
    bool clearError = false,
  }) {
    return MapEventAttendeesState(
      status: status ?? this.status,
      filter: filter ?? this.filter,
      attendees: attendees ?? this.attendees,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props =>
      [status, filter, attendees, nextCursor, isLoadingMore, error];
}
