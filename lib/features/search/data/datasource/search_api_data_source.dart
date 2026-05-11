import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/abstract_http.dart';
import '../models/search_result_model.dart';

@lazySingleton
class SearchApiDataSource {
  final AbstractHTTP http;

  SearchApiDataSource(this.http);

  Future<List<SearchResultModel>> searchUsers(
    String query, {
    CancelToken? cancelToken,
  }) async {
    final data = await http.get(
      '/profile/search',
      queryParameters: {'q': query},
      cancelToken: cancelToken,
    );

    final list = data as List<dynamic>;
    return list
        .map((e) => SearchResultModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
