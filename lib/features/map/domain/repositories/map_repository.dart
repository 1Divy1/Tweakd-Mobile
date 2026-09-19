import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/base_failures.dart';
import '../entities/business_detail_entity.dart';
import '../entities/business_pin_entity.dart';
import '../entities/business_search_page.dart';
import '../entities/geo_position.dart';

abstract class MapRepository {
  /// Businesses within [radiusKm] of [centre], nearest-first.
  ///
  /// [typeId] narrows to a single business type when set; leaving it null asks
  /// for all of them.
  Future<Either<Failure, List<BusinessPinEntity>>> getNearbyBusinesses({
    required GeoPosition centre,
    required double radiusKm,
    String? typeId,
    int? limit,
    CancelToken? cancelToken,
  });

  /// The map's search box: businesses whose name or type contains [query],
  /// nearest to [centre] first, anywhere on the map (no radius). Pass the
  /// previous page's cursor — with the same [centre] — to continue.
  Future<Either<Failure, BusinessSearchPageEntity>> searchBusinesses({
    required String query,
    required GeoPosition centre,
    String? cursor,
    int? size,
    CancelToken? cancelToken,
  });

  /// The full profile behind a pin. A hidden business is indistinguishable
  /// from a nonexistent one — both surface as [BusinessNotFoundFailure].
  Future<Either<Failure, BusinessDetailEntity>> getBusinessDetail(
    String id, {
    CancelToken? cancelToken,
  });

  /// The device's current position, asking for permission if it hasn't been
  /// decided yet. Returns [LocationUnavailableFailure] on any refusal — the
  /// caller is expected to fall back rather than show an error.
  Future<Either<Failure, GeoPosition>> getCurrentPosition();
}
