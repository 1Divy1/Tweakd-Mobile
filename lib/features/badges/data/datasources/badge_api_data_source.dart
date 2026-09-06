import 'package:injectable/injectable.dart';

import '../../../../core/network/abstract_http.dart';
import '../models/badge_model.dart';
import '../models/user_badge_model.dart';
import 'badge_data_source.dart';

@LazySingleton(as: BadgeDataSource)
class BadgeApiDataSource implements BadgeDataSource {
  final AbstractHTTP http;

  BadgeApiDataSource(this.http);

  /// GET /badges/me/locked — a flat array of badge objects, no `earned_at`
  /// (nothing was earned). Retired badges are excluded server-side.
  @override
  Future<List<BadgeModel>> getMyLockedBadges() async {
    final data = await http.get('/badges/me/locked');
    return (data as List)
        .map((e) => BadgeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /badges/me/pending-celebration — `UserBadgeDto[]`, oldest unlock
  /// first. Same shape as the feed's `pending_badge_celebrations`.
  @override
  Future<List<UserBadgeModel>> getPendingCelebrations() async {
    final data = await http.get('/badges/me/pending-celebration');
    return (data as List)
        .map((e) => UserBadgeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /badges/me/pending-celebration/{badgeId} — no body. Returns
  /// `{"celebrated": bool}`; the flag is not surfaced (a repeat ack is a
  /// no-op, not a failure), so the response is ignored.
  @override
  Future<void> markCelebrated(String badgeId) =>
      http.post('/badges/me/pending-celebration/$badgeId');
}
