/// Request payload for creating a post (text only — images are attached in a
/// separate step). Count flags default to true on the backend when omitted, but
/// they are always sent explicitly here to mirror the wizard's toggles.
class CreatePostParams {
  final String? description;
  final List<String> taggedPeople;
  final List<String> taggedCars;
  final bool likesCountEnabled;
  final bool commentsCountEnabled;
  final bool sharesCountEnabled;
  final bool savedCountEnabled;

  const CreatePostParams({
    this.description,
    this.taggedPeople = const [],
    this.taggedCars = const [],
    this.likesCountEnabled = true,
    this.commentsCountEnabled = true,
    this.sharesCountEnabled = true,
    this.savedCountEnabled = true,
  });

  Map<String, dynamic> toJson() => {
        if (description != null && description!.trim().isNotEmpty)
          'description': description!.trim(),
        'tagged_people': taggedPeople,
        'tagged_cars': taggedCars,
        'likes_count_enabled': likesCountEnabled,
        'comments_count_enabled': commentsCountEnabled,
        'shares_count_enabled': sharesCountEnabled,
        'saved_count_enabled': savedCountEnabled,
      };
}

/// Request payload for updating a post. Every field is optional; a null field is
/// left unchanged. A non-null [taggedPeople]/[taggedCars] replaces the whole set
/// (an empty list clears it). Images are not touched here.
class UpdatePostParams {
  final String? description;
  final List<String>? taggedPeople;
  final List<String>? taggedCars;
  final bool? likesCountEnabled;
  final bool? commentsCountEnabled;
  final bool? sharesCountEnabled;
  final bool? savedCountEnabled;

  const UpdatePostParams({
    this.description,
    this.taggedPeople,
    this.taggedCars,
    this.likesCountEnabled,
    this.commentsCountEnabled,
    this.sharesCountEnabled,
    this.savedCountEnabled,
  });

  Map<String, dynamic> toJson() => {
        if (description != null) 'description': description,
        if (taggedPeople != null) 'tagged_people': taggedPeople,
        if (taggedCars != null) 'tagged_cars': taggedCars,
        if (likesCountEnabled != null) 'likes_count_enabled': likesCountEnabled,
        if (commentsCountEnabled != null)
          'comments_count_enabled': commentsCountEnabled,
        if (sharesCountEnabled != null)
          'shares_count_enabled': sharesCountEnabled,
        if (savedCountEnabled != null) 'saved_count_enabled': savedCountEnabled,
      };
}

/// Shares one of the viewer's participant cards to the feed. It only names
/// the card — the backend checks it is theirs and derives everything on it.
class ShareParticipantCardParams {
  final String eventId;
  final String carId;
  final String? description;

  const ShareParticipantCardParams({
    required this.eventId,
    required this.carId,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'event_id': eventId,
        'car_id': carId,
        if (description != null && description!.trim().isNotEmpty)
          'description': description!.trim(),
      };
}
