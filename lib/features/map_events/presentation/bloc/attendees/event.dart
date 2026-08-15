import 'package:equatable/equatable.dart';

import '../../../domain/entities/map_event_enums.dart';

sealed class MapEventAttendeesEvent extends Equatable {
  const MapEventAttendeesEvent();

  @override
  List<Object?> get props => [];
}

class LoadMapEventAttendees extends MapEventAttendeesEvent {
  final String eventId;

  const LoadMapEventAttendees(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

/// Switch between the Attending and Interested lists. Each is its own query, so
/// this refetches from the first page rather than filtering locally.
class ChangeAttendeeFilter extends MapEventAttendeesEvent {
  final MapEventAttendance status;

  const ChangeAttendeeFilter(this.status);

  @override
  List<Object?> get props => [status];
}

class LoadMoreMapEventAttendees extends MapEventAttendeesEvent {
  const LoadMoreMapEventAttendees();
}
