import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/business_search_page.dart';
import '../entities/geo_position.dart';
import '../repositories/map_repository.dart';

class SearchBusinessesParams {
  final String query;
  final GeoPosition centre;
  final String? cursor;
  final int? size;
  final CancelToken? cancelToken;

  const SearchBusinessesParams({
    required this.query,
    required this.centre,
    this.cursor,
    this.size,
    this.cancelToken,
  });
}

@lazySingleton
class SearchBusinessesUseCase
    implements UseCase<BusinessSearchPageEntity, SearchBusinessesParams> {
  final MapRepository repository;

  SearchBusinessesUseCase(this.repository);

  @override
  Future<Either<Failure, BusinessSearchPageEntity>> call(
    SearchBusinessesParams params,
  ) {
    return repository.searchBusinesses(
      query: params.query,
      centre: params.centre,
      cursor: params.cursor,
      size: params.size,
      cancelToken: params.cancelToken,
    );
  }
}
