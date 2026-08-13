import 'package:equatable/equatable.dart';

import 'map_event_enums.dart';

/// A search hit from `GET /map-events/organizers/search` — someone who could be
/// added as a co-organizer. Individuals and businesses come back merged and
/// unsorted between the two groups.
class OrganizerCandidateEntity extends Equatable {
  final MapEventOrganizerType type;

  /// The user id or business id, depending on [type]. This is what gets fed to
  /// `POST /{id}/organizers` as `user_id` **or** `business_id` — exactly one of
  /// the two, matching [type].
  final String referenceId;

  final String name;

  /// Individuals only — null on a business hit.
  final String? username;

  final String? imageUrl;

  const OrganizerCandidateEntity({
    required this.type,
    required this.referenceId,
    required this.name,
    required this.username,
    required this.imageUrl,
  });

  bool get isBusiness => type == MapEventOrganizerType.business;

  @override
  List<Object?> get props => [type, referenceId, name, username, imageUrl];
}
