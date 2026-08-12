import 'package:equatable/equatable.dart';

import 'map_event_enums.dart';

/// One row of `GET /map-events/{id}/attendees` — a spectator RSVP.
///
/// Flattened from the wire's `{ profile: {...}, status }`: the profile is the
/// only thing inside, and every consumer wants both halves together.
class MapEventAttendeeEntity extends Equatable {
  final String id;
  final String username;
  final String? avatarUrl;
  final MapEventAttendance status;

  const MapEventAttendeeEntity({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.status,
  });

  @override
  List<Object?> get props => [id, username, avatarUrl, status];
}
