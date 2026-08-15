// The wire vocabularies of the `/map-events/*` module.
//
// Every enum here mirrors a backend string. They all parse defensively: a
// value the app doesn't know about must never crash a list — it falls back to
// the least surprising member, and callers that care about the difference
// check explicitly.

/// Where an event sits in its own timeline. Distinct from [MapEventApproval],
/// which is about the admin team letting it exist at all.
enum MapEventStatus {
  upcoming,
  live,
  previous,
  hidden,
  canceled;

  static MapEventStatus fromApi(String? value) => switch (value) {
        'upcoming' => MapEventStatus.upcoming,
        'live' => MapEventStatus.live,
        'previous' => MapEventStatus.previous,
        'hidden' => MapEventStatus.hidden,
        'canceled' => MapEventStatus.canceled,
        _ => MapEventStatus.upcoming,
      };

  String get apiValue => name;

  /// Whether the event is still something a viewer can act on — RSVP, register
  /// a car, withdraw. Finished, hidden and canceled events are read-only.
  bool get isActionable =>
      this == MapEventStatus.upcoming || this == MapEventStatus.live;
}

/// The admin team's verdict. Only `accepted` events reach the public map;
/// `pending` and `rejected` are visible to their own organizers via `/mine`.
enum MapEventApproval {
  pending,
  accepted,
  rejected;

  static MapEventApproval fromApi(String? value) => switch (value) {
        'pending' => MapEventApproval.pending,
        'accepted' => MapEventApproval.accepted,
        'rejected' => MapEventApproval.rejected,
        _ => MapEventApproval.pending,
      };

  String get apiValue => name;

  /// Editing is locked once the admins accept an event — `PATCH /{id}` and
  /// `PUT /{id}/rules` both only work while pending or rejected.
  bool get isEditable =>
      this == MapEventApproval.pending || this == MapEventApproval.rejected;
}

/// A spectator RSVP. Absent (null on the viewer object) means no RSVP at all.
enum MapEventAttendance {
  attending,
  interested;

  static MapEventAttendance? fromApi(String? value) => switch (value) {
        'attending' => MapEventAttendance.attending,
        'interested' => MapEventAttendance.interested,
        _ => null,
      };

  String get apiValue => name;
}

/// The state of one car's entry in an event.
///
/// `withdrawn` is not a removal: it's a request the organizers still have to
/// approve (hard delete) or reject (back to `accepted`). Withdrawn rows stay
/// publicly visible in the meantime — deliberately, since asking to leave
/// carries no stigma.
enum MapEventParticipation {
  pending,
  accepted,
  rejected,
  withdrawn;

  static MapEventParticipation fromApi(String? value) => switch (value) {
        'pending' => MapEventParticipation.pending,
        'accepted' => MapEventParticipation.accepted,
        'rejected' => MapEventParticipation.rejected,
        'withdrawn' => MapEventParticipation.withdrawn,
        _ => MapEventParticipation.pending,
      };

  String get apiValue => name;
}

/// Whether an organizer (or a candidate for the role) is a person or a
/// certified business account.
enum MapEventOrganizerType {
  individual,
  business;

  static MapEventOrganizerType fromApi(String? value) => switch (value) {
        'business' => MapEventOrganizerType.business,
        _ => MapEventOrganizerType.individual,
      };

  String get apiValue => name;
}

/// Creator vs. co-organizer. Only the creator may add/remove organizers or
/// delete the event.
enum MapEventOrganizerRole {
  creator,
  organizer;

  static MapEventOrganizerRole fromApi(String? value) => switch (value) {
        'creator' => MapEventOrganizerRole.creator,
        _ => MapEventOrganizerRole.organizer,
      };

  String get apiValue => name;
}
