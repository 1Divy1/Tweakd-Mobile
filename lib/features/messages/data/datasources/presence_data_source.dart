import 'package:injectable/injectable.dart';

import '../../../../core/network/abstract_http.dart';
import '../models/presence_model.dart';

/// Batch presence lookup. Real from day one (unlike the still-mocked DM
/// endpoints): `GET /presence?user_ids=<uuid>,<uuid>`.
abstract class PresenceDataSource {
  Future<List<PresenceModel>> getPresence(List<String> userIds);
}

@LazySingleton(as: PresenceDataSource)
class PresenceApiDataSource implements PresenceDataSource {
  final AbstractHTTP http;

  /// Server rejects requests with more than 100 ids (400), so larger lookups
  /// are split into compliant batches.
  static const _batchLimit = 100;

  PresenceApiDataSource(this.http);

  @override
  Future<List<PresenceModel>> getPresence(List<String> userIds) async {
    final ids = userIds.toSet().toList();
    if (ids.isEmpty) return const [];

    final results = <PresenceModel>[];
    for (var i = 0; i < ids.length; i += _batchLimit) {
      final batch = ids.sublist(
        i,
        i + _batchLimit > ids.length ? ids.length : i + _batchLimit,
      );
      final data = await http.get(
        '/presence',
        queryParameters: {'user_ids': batch.join(',')},
      );
      if (data is List) {
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            results.add(PresenceModel.fromJson(item));
          }
        }
      }
    }
    return results;
  }
}
