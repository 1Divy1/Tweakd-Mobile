import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/error/base_failures.dart';
import '../../domain/entities/car.dart';
import '../../domain/entities/car_image.dart';
import '../../domain/entities/car_status_option.dart';
import '../../domain/entities/create_car_result.dart';
import '../../domain/entities/garage.dart';
import '../../domain/entities/reference_data.dart';
import '../../domain/failures/garage_failures.dart';
import '../../domain/repositories/garage_repository.dart';
import '../datasources/garage_api_data_source.dart';

@LazySingleton(as: GarageRepository)
class GarageRepositoryImpl implements GarageRepository {
  final GarageApiDataSource dataSource;

  GarageRepositoryImpl(this.dataSource);

  // ── Garage ────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, GarageEntity>> getMyGarage() async {
    try {
      final model = await dataSource.getMyGarage();
      return Right(model.toEntity());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 404) return const Left(GarageNotFoundFailure());
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('getMyGarage error: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, GarageEntity>> getGarageByUsername(
      String username) async {
    try {
      final model = await dataSource.getGarageByUsername(username);
      return Right(model.toEntity());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 403) return const Left(PrivateGarageFailure());
      if (e.statusCode == 404) return const Left(GarageNotFoundFailure());
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('getGarageByUsername error: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  // ── Cars ──────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, CarEntity>> getCar(String carId) async {
    try {
      final model = await dataSource.getCar(carId);
      return Right(model.toEntity());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 403) return const Left(PrivateGarageFailure());
      if (e.statusCode == 404) return const Left(CarNotFoundFailure());
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('getCar error: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, CreateCarResult>> addCar(
      CreateCarParams params) async {
    try {
      final model = await dataSource.addCar(params.toJson());
      return Right(model.toEntity());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 400) return Left(InvalidReferenceFailure(e.message));
      if (e.statusCode == 404) return const Left(GarageNotFoundFailure());
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('addCar error: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, CarEntity>> updateCar(
    String carId,
    CarRequestParams params,
  ) async {
    try {
      final model = await dataSource.updateCar(carId, params.toJson());
      return Right(model.toEntity());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 400) return Left(InvalidReferenceFailure(e.message));
      if (e.statusCode == 403) return const Left(NotCarOwnerFailure());
      if (e.statusCode == 404) return const Left(CarNotFoundFailure());
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('updateCar error: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCar(String carId) async {
    try {
      await dataSource.deleteCar(carId);
      return const Right(null);
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 403) return const Left(NotCarOwnerFailure());
      if (e.statusCode == 404) return const Left(CarNotFoundFailure());
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('deleteCar error: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  // ── Modifications ─────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, AddModificationResult>> addModification(
    String carId,
    ModRequestParams params,
  ) async {
    try {
      final model = await dataSource.addModification(carId, params.toJson());
      return Right(model.toEntity());
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 403) return const Left(NotCarOwnerFailure());
      if (e.statusCode == 404) return const Left(CarNotFoundFailure());
      if (e.statusCode == 400) return Left(InvalidReferenceFailure(e.message));
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('addModification error: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, void>> updateModification(
    String carId,
    String modId,
    ModRequestParams params,
  ) async {
    try {
      await dataSource.updateModification(carId, modId, params.toJson());
      return const Right(null);
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 403) return const Left(NotCarOwnerFailure());
      if (e.statusCode == 404) return const Left(CarNotFoundFailure());
      if (e.statusCode == 400) return Left(InvalidReferenceFailure(e.message));
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('updateModification error: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteModification(
      String carId, String modId) async {
    try {
      await dataSource.deleteModification(carId, modId);
      return const Right(null);
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 403) return const Left(NotCarOwnerFailure());
      if (e.statusCode == 404) return const Left(CarNotFoundFailure());
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('deleteModification error: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  // ── Gallery images ────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<CarImageEntity>>> listCarImages(
      String carId) async {
    try {
      final models = await dataSource.listCarImages(carId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ApiException catch (e) {
      if (e.statusCode == 403) return const Left(PrivateGarageFailure());
      if (e.statusCode == 404) return const Left(CarNotFoundFailure());
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('listCarImages error: $e');
      return const Left(UnknownFailure('Failed to load gallery.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCarImage(
      String carId, String imageId) async {
    try {
      await dataSource.deleteCarImage(carId, imageId);
      return const Right(null);
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ApiException catch (e) {
      if (e.statusCode == 403) return const Left(NotCarOwnerFailure());
      if (e.statusCode == 404) return const Left(CarNotFoundFailure());
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('deleteCarImage error: $e');
      return const Left(UnknownFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, String>> resolveImageUrl(String storagePath) async {
    try {
      final url = await dataSource.generateDownloadUrl(storagePath);
      return Right(url);
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ApiException catch (e) {
      if (e.statusCode == 403) return const Left(PrivateGarageFailure());
      if (e.statusCode == 404) return const Left(CarNotFoundFailure());
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('resolveImageUrl error: $e');
      return const Left(UnknownFailure('Failed to load image.'));
    }
  }

  // ── Reference data ────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<CarBrandEntity>>> getBrands() async {
    try {
      final models = await dataSource.getBrands();
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } catch (e) {
      return const Left(UnknownFailure('Failed to load brands.'));
    }
  }

  @override
  Future<Either<Failure, List<CarModelEntity>>> getModelsByBrand(
      String brandId) async {
    try {
      final models = await dataSource.getModelsByBrand(brandId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } catch (e) {
      return const Left(UnknownFailure('Failed to load models.'));
    }
  }

  @override
  Future<Either<Failure, List<CarDrivetrainEntity>>> getDrivetrains() async {
    try {
      final models = await dataSource.getDrivetrains();
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } catch (e) {
      return const Left(UnknownFailure('Failed to load drivetrains.'));
    }
  }

  @override
  Future<Either<Failure, List<CarColorEntity>>> getColors() async {
    try {
      final models = await dataSource.getColors();
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } catch (e) {
      return const Left(UnknownFailure('Failed to load colors.'));
    }
  }

  @override
  Future<Either<Failure, List<CarDistanceUnitEntity>>> getDistanceUnits() async {
    try {
      final models = await dataSource.getDistanceUnits();
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } catch (e) {
      return const Left(UnknownFailure('Failed to load distance units.'));
    }
  }

  @override
  Future<Either<Failure, List<CarStatusOptionEntity>>> getStatusOptions() async {
    try {
      final models = await dataSource.getStatusOptions();
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } catch (e) {
      return const Left(UnknownFailure('Failed to load status options.'));
    }
  }

  @override
  Future<Either<Failure, List<CarModCategoryEntity>>> getModCategories() async {
    try {
      final models = await dataSource.getModCategories();
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } catch (e) {
      return const Left(UnknownFailure('Failed to load mod categories.'));
    }
  }
}
