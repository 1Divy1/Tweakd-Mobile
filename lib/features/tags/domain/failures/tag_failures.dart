import 'package:car_social_media_app/core/error/base_failures.dart';

/// The content behind a tag no longer exists (404 on untag) — e.g. the post or
/// thread was deleted. Untagging something you simply aren't tagged in is a
/// no-op 204, not this failure.
class TaggedContentNotFoundFailure extends Failure {
  const TaggedContentNotFoundFailure()
      : super(message: 'That content no longer exists.');
}

/// The paging cursor was rejected (400) — malformed or corrupted. Recoverable
/// by reloading the feed from the start.
class InvalidTagCursorFailure extends Failure {
  const InvalidTagCursorFailure() : super(message: 'Invalid page cursor.');
}
