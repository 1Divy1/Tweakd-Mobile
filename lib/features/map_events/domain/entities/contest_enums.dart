// The wire vocabularies of `/map-events/{id}/contests`.
//
// Every enum parses defensively, like the event enums: a value the app doesn't
// know must never crash a list.

/// Where a contest sits in its own timeline.
enum ContestStatus {
  /// Published; entries open; voting locked until `opens_at`.
  scheduled,

  /// Voting.
  open,

  /// Results are final; the podium has been awarded.
  finished,

  /// Reserved on the backend; nothing writes it today.
  canceled;

  static ContestStatus fromApi(String? value) => switch (value) {
        'scheduled' => ContestStatus.scheduled,
        'open' => ContestStatus.open,
        'finished' => ContestStatus.finished,
        'canceled' => ContestStatus.canceled,
        _ => ContestStatus.scheduled,
      };

  String get apiValue => name;
}

/// The state of one car's request to be judged in a contest.
enum ContestEntryStatus {
  pending,
  accepted,
  rejected,
  withdrawn;

  static ContestEntryStatus fromApi(String? value) => switch (value) {
        'pending' => ContestEntryStatus.pending,
        'accepted' => ContestEntryStatus.accepted,
        'rejected' => ContestEntryStatus.rejected,
        'withdrawn' => ContestEntryStatus.withdrawn,
        _ => ContestEntryStatus.pending,
      };

  String get apiValue => name;

  /// Whether the row still counts as "in" — on the ballot or waiting to be.
  bool get isLive =>
      this == ContestEntryStatus.pending || this == ContestEntryStatus.accepted;
}

/// The glyph a contest category is drawn with. Mirrors the backend's `icon`
/// key; anything unrecognised is a trophy, which is never wrong for a contest.
enum ContestCategoryIcon {
  exhaust,
  wheels,
  paint,
  interior,
  loud,
  trophy;

  static ContestCategoryIcon fromApi(String? value) => switch (value) {
        'exhaust' => ContestCategoryIcon.exhaust,
        'wheels' => ContestCategoryIcon.wheels,
        'paint' => ContestCategoryIcon.paint,
        'interior' => ContestCategoryIcon.interior,
        'loud' => ContestCategoryIcon.loud,
        _ => ContestCategoryIcon.trophy,
      };
}
