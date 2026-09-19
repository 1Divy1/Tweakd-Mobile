import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/error/base_failures.dart';
import '../../domain/entities/business_detail_entity.dart';
import '../../domain/entities/business_pin_entity.dart';
import '../../domain/entities/business_search_page.dart';
import '../../domain/entities/geo_position.dart';
import '../../domain/failures/map_failures.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasources/business_api_data_source.dart';
import '../datasources/device_location_data_source.dart';
import '../exceptions/map_exceptions.dart';

@LazySingleton(as: MapRepository)
class MapRepositoryImpl implements MapRepository {
  final BusinessApiDataSource businessApiDataSource;
  final DeviceLocationDataSource deviceLocationDataSource;

  MapRepositoryImpl(this.businessApiDataSource, this.deviceLocationDataSource);

  @override
  Future<Either<Failure, List<BusinessPinEntity>>> getNearbyBusinesses({
    required GeoPosition centre,
    required double radiusKm,
    String? typeId,
    int? limit,
    CancelToken? cancelToken,
  }) async {
    try {
      final pins = await businessApiDataSource.getNearby(
        lat: centre.lat,
        lng: centre.lng,
        radiusKm: radiusKm,
        typeId: typeId,
        limit: limit,
        cancelToken: cancelToken,
      );
      return Right([for (final p in pins) p.toEntity()]);
    } on RequestCancelledException {
      return const Left(RequestCancelledFailure());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('Unexpected error in getNearbyBusinesses: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, BusinessSearchPageEntity>> searchBusinesses({
    required String query,
    required GeoPosition centre,
    String? cursor,
    int? size,
    CancelToken? cancelToken,
  }) async {
    try {
      final page = await businessApiDataSource.search(
        query: query,
        lat: centre.lat,
        lng: centre.lng,
        cursor: cursor,
        size: size,
        cancelToken: cancelToken,
      );
      return Right(page.toEntity());
    } on RequestCancelledException {
      return const Left(RequestCancelledFailure());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('Unexpected error in searchBusinesses: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, BusinessDetailEntity>> getBusinessDetail(
    String id, {
    CancelToken? cancelToken,
  }) async {
    try {
      final detail = await businessApiDataSource.getById(
        id,
        cancelToken: cancelToken,
      );
      return Right(detail.toEntity());
    } on RequestCancelledException {
      return const Left(RequestCancelledFailure());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      // 404 covers deleted *and* hidden (pending/suspended/rejected) — the
      // backend deliberately doesn't distinguish them, and neither do we.
      if (e.statusCode == 404) {
        return Left(BusinessNotFoundFailure(e.message));
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('Unexpected error in getBusinessDetail: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, GeoPosition>> getCurrentPosition() async {
    try {
      final fix = await deviceLocationDataSource.getCurrentPosition();
      return Right(GeoPosition(lat: fix.lat, lng: fix.lng));
    } on LocationUnavailableException catch (e) {
      return Left(LocationUnavailableFailure(e.message));
    } catch (e) {
      debugPrint('Unexpected error in getCurrentPosition: $e');
      return const Left(LocationUnavailableFailure('Location unavailable.'));
    }
  }
}
