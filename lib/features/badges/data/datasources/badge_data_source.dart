import '../models/badge_model.dart';

/// The seam between the badge repository and the backend.
///
/// Only the locked list lives here. **Earned badges are not fetched** — they
/// ride along with the profile payload (`badges` on both `/profile/me` and
/// `/profile/by-username/{username}`), so the strip has them the moment the
/// header does. `GET /badges/me` and `/profile/by-username/{u}/badges` exist
/// for refetching a badge row after an unlock animation; the app refreshes the
/// whole profile instead, which carries the same data.
abstract class BadgeDataSource {
  /// The badges the signed-in user has *not* earned yet. Own profile only —
  /// there is deliberately no public equivalent.
  Future<List<BadgeModel>> getMyLockedBadges();
}
