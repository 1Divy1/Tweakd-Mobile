import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/abstract_http.dart';
import '../models/business_detail_model.dart';
import '../models/business_pin_model.dart';

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

  /// `GET /businesses/{id}` — the full profile behind a pin.
  Future<BusinessDetailModel> getById(
    String id, {
    CancelToken? cancelToken,
  }) async {
    final data = await http.get('/businesses/$id', cancelToken: cancelToken);
    BusinessDetailModel model = BusinessDetailModel.fromJson(data as Map<String, dynamic>);
    
    // TODO: debug only
    debugPrint("Logo URL: ${model.logoUrl}");

    return model;
  }
}
