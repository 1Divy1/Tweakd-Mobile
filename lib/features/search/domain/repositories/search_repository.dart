import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/base_failures.dart';
import '../entities/search_result.dart';

abstract class SearchRepository {
  Future<Either<Failure, List<SearchResultEntity>>> searchUsers(
    String query, {
    CancelToken? cancelToken,
  });
}
