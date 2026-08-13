import 'package:equatable/equatable.dart';

import 'map_event_enums.dart';

/// One row of `GET /map-events/{id}/attendees` — a spectator RSVP.
///
/// Flattened from the wire's `{ profile: {...}, status }`: the profile is the
/// only thing inside, and every consumer wants both halves together.
class MapEventAttendeeEntity extends Equatable {
  final String id;
  final String username;

  /// Display name. The shared profile DTO only started carrying it recently,
  /// so it can still be absent — the row falls back to the handle.
  final String? name;

  final String? avatarUrl;
  final MapEventAttendance status;

  const MapEventAttendeeEntity({
    required this.id,
    required this.username,
    required this.name,
    required this.avatarUrl,
    required this.status,
  });

  @override
  List<Object?> get props => [id, username, name, avatarUrl, status];
}
