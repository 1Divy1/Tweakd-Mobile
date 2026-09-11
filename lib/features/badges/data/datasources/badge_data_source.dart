import '../models/user_badge_model.dart';

/// The seam between the badge repository and the backend.
///
/// One read lives here: the pending-celebration list that drives the one-time
/// unlock animation. **Earned badges are not fetched** — they ride along with the profile payload
/// (`badges` on both `/profile/me` and `/profile/by-username/{username}`), so
/// the strip has them the moment the header does. `GET /badges/me` and
/// `/profile/by-username/{u}/badges` exist for refetching a badge row after an
/// unlock animation; the app refreshes the whole profile instead, which carries
/// the same data.
abstract class BadgeDataSource {
  /// The caller's earned badges whose one-time unlock animation the app still
  /// owes them, oldest unlock first.
  ///
  /// The launch payload already carries this list on the first page of
  /// `GET /feed/global` (`pending_badge_celebrations`), so the app does **not**
  /// call this on start. It is here only for a re-check during a long-running
  /// session.
  Future<List<UserBadgeModel>> getPendingCelebrations();

  /// Records that the app has finished the unlock animation for one badge, so
  /// it drops off [getPendingCelebrations]. Idempotent and never an error —
  /// a repeat call, or one for a badge the caller does not hold, is a no-op
  /// server-side.
  Future<void> markCelebrated(String badgeId);
}
