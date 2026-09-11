import 'package:tweakd/core/network/abstract_http.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/contest_models.dart';
import '../models/map_event_json.dart';
import '../models/participant_card_model.dart';

/// `/api/v1/map-events/{id}/contests/*` and the car history read.
///
/// Bodies are explicit maps: the PATCH omits what it doesn't change, and that
/// distinction is easier to keep honest inline than through a model's toJson.
@lazySingleton
class MapEventContestsApiDataSource {
  final AbstractHTTP http;

  MapEventContestsApiDataSource(this.http);

  Future<List<ContestCategoryModel>> getCategories() async {
    final data = await http.get('/map-events/contest-categories');
    return [
      for (final e in data as List<dynamic>)
        ContestCategoryModel.fromJson(e as Map<String, dynamic>),
    ];
  }

  Future<List<ContestModel>> getContests(
    String eventId, {
    CancelToken? cancelToken,
  }) async {
    final data = await http.get(
      '/map-events/$eventId/contests',
      cancelToken: cancelToken,
    );
    return [
      for (final e in data as List<dynamic>)
        ContestModel.fromJson(e as Map<String, dynamic>),
    ];
  }

  /// The viewer's participant cards for an event — one per accepted car.
  /// Empty until an organizer marks the event finished. Rows that fail to
  /// decode are dropped rather than failing the whole list.
  Future<List<ParticipantCardModel>> getMyParticipantCards(
    String eventId, {
    CancelToken? cancelToken,
  }) async {
    final data = await http.get(
      '/map-events/$eventId/cards',
      cancelToken: cancelToken,
    );
    return [
      for (final e in data as List<dynamic>)
        ?ParticipantCardModel.tryParse(e),
    ];
  }

  Future<ContestModel> getContest(
    String eventId,
    String contestId, {
    CancelToken? cancelToken,
  }) async {
    final data = await http.get(
      '/map-events/$eventId/contests/$contestId',
      cancelToken: cancelToken,
    );
    return ContestModel.fromJson(data as Map<String, dynamic>);
  }

  Future<ContestModel> createContest(
    String eventId, {
    required String categoryId,
    required String title,
    String? criteria,
    required DateTime opensAt,
    required DateTime closesAt,
  }) async {
    final data = await http.post(
      '/map-events/$eventId/contests',
      body: {
        'category_id': categoryId,
        'title': title,
        'criteria': ?criteria,
        'opens_at': formatInstant(opensAt),
        'closes_at': formatInstant(closesAt),
      },
    );
    return ContestModel.fromJson(data as Map<String, dynamic>);
  }

  Future<ContestModel> updateContest(
    String eventId,
    String contestId, {
    String? title,
    String? criteria,
    DateTime? opensAt,
    DateTime? closesAt,
  }) async {
    final data = await http.patch(
      '/map-events/$eventId/contests/$contestId',
      body: {
        'title': ?title,
        'criteria': ?criteria,
        if (opensAt != null) 'opens_at': formatInstant(opensAt),
        if (closesAt != null) 'closes_at': formatInstant(closesAt),
      },
    );
    return ContestModel.fromJson(data as Map<String, dynamic>);
  }

  Future<ContestModel> openContest(String eventId, String contestId) async {
    final data = await http.post('/map-events/$eventId/contests/$contestId/open');
    return ContestModel.fromJson(data as Map<String, dynamic>);
  }

  Future<ContestModel> finishContest(String eventId, String contestId) async {
    final data = await http.post('/map-events/$eventId/contests/$contestId/finish');
    return ContestModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteContest(String eventId, String contestId) async {
    await http.delete('/map-events/$eventId/contests/$contestId');
  }

  Future<ContestModel> requestEntry(
    String eventId,
    String contestId,
    String carId,
  ) async {
    final data = await http.post(
      '/map-events/$eventId/contests/$contestId/entries',
      body: {'car_id': carId},
    );
    return ContestModel.fromJson(data as Map<String, dynamic>);
  }

  Future<ContestModel> withdrawEntry(
    String eventId,
    String contestId,
    String carId,
  ) async {
    final data = await http.delete(
      '/map-events/$eventId/contests/$contestId/entries/$carId',
    );
    return ContestModel.fromJson(data as Map<String, dynamic>);
  }

  Future<ContestModel> decideEntry(
    String eventId,
    String contestId,
    String carId, {
    required String status,
    String? reason,
  }) async {
    final data = await http.patch(
      '/map-events/$eventId/contests/$contestId/entries/$carId',
      body: {'status': status, 'reason': ?reason},
    );
    return ContestModel.fromJson(data as Map<String, dynamic>);
  }

  Future<ContestModel> vote(String eventId, String contestId, String carId) async {
    final data = await http.put(
      '/map-events/$eventId/contests/$contestId/vote',
      body: {'car_id': carId},
    );
    return ContestModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<CarEventHistoryItemModel>> getCarHistory(
    String carId, {
    CancelToken? cancelToken,
  }) async {
    final data = await http.get(
      '/map-events/cars/$carId/history',
      cancelToken: cancelToken,
    );
    return [
      for (final e in data as List<dynamic>)
        CarEventHistoryItemModel.fromJson(e as Map<String, dynamic>),
    ];
  }
}
