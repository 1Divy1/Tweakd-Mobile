import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/abstract_http.dart';
import '../models/business_detail_model.dart';
import '../models/business_pin_model.dart';
import '../models/business_search_page_model.dart';

@lazySingleton
class BusinessApiDataSource {
  final AbstractHTTP http;

  BusinessApiDataSource(this.http);

  /// `GET /businesses/nearby` — map pins around a centre, nearest-first.
  ///
  /// The backend rejects `radius_km > 500` and `limit > 500` with a 400, so
  /// callers must stay inside those bounds.
  Future<List<BusinessPinModel>> getNearby({
    required double lat,
    required double lng,
    required double radiusKm,
    String? typeId,
    int? limit,
    CancelToken? cancelToken,
  }) async {
    final data = await http.get(
      '/businesses/nearby',
      queryParameters: {
        'lat': lat,
        'lng': lng,
        'radius_km': radiusKm,
        'type': ?typeId,
        'limit': ?limit,
      },
      cancelToken: cancelToken,
    );

    final list = data as List<dynamic>;
    return list
        .map((e) => BusinessPinModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `GET /businesses/search` — the map's search box: name or type contains
  /// [query], nearest to [lat]/[lng] first, one keyset page at a time. Send
  /// the same centre with every page of one search.
  Future<BusinessSearchPageModel> search({
    required String query,
    required double lat,
    required double lng,
    String? cursor,
    int? size,
    CancelToken? cancelToken,
  }) async {
    final data = await http.get(
      '/businesses/search',
      queryParameters: {
        'q': query,
        'lat': lat,
        'lng': lng,
        'cursor': ?cursor,
        'size': ?size,
      },
      cancelToken: cancelToken,
    );
    return BusinessSearchPageModel.fromJson(data as Map<String, dynamic>);
  }

  /// `GET /businesses/{id}` — the full profile behind a pin.
  Future<BusinessDetailModel> getById(
    String id, {
    CancelToken? cancelToken,
  }) async {
    final data = await http.get('/businesses/$id', cancelToken: cancelToken);
    BusinessDetailModel model = BusinessDetailModel.fromJson(data as Map<String, dynamic>);

    return model;
  }
}
