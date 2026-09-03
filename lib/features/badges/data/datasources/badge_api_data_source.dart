import 'package:injectable/injectable.dart';

import '../../../../core/network/abstract_http.dart';
import '../models/badge_model.dart';
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
}
