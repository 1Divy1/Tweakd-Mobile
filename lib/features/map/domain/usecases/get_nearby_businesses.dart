import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/business_pin_entity.dart';
import '../entities/geo_position.dart';
import '../repositories/map_repository.dart';

class GetNearbyBusinessesParams {
  final GeoPosition centre;
  final double radiusKm;
  final String? typeId;
  final int? limit;
  final CancelToken? cancelToken;

  const GetNearbyBusinessesParams({
    required this.centre,
    required this.radiusKm,
    this.typeId,
    this.limit,
    this.cancelToken,
  });
}

@lazySingleton
class GetNearbyBusinessesUseCase
    implements UseCase<List<BusinessPinEntity>, GetNearbyBusinessesParams> {
  final MapRepository repository;

  GetNearbyBusinessesUseCase(this.repository);

  @override
  Future<Either<Failure, List<BusinessPinEntity>>> call(
    GetNearbyBusinessesParams params,
  ) {
    return repository.getNearbyBusinesses(
      centre: params.centre,
      radiusKm: params.radiusKm,
      typeId: params.typeId,
      limit: params.limit,
      cancelToken: params.cancelToken,
    );
  }
}
