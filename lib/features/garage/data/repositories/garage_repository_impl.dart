import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_exceptions.dart';
import '../../../../core/error/base_failures.dart';
import '../../../../core/services/car_image_service.dart';
import '../../domain/entities/car.dart';
import '../../domain/entities/car_modification.dart';
import '../../domain/entities/car_status_option.dart';
import '../../domain/entities/create_car_result.dart';
import '../../domain/entities/garage.dart';
import '../../domain/entities/reference_data.dart';
import '../../domain/failures/garage_failures.dart';
import '../../domain/repositories/garage_repository.dart';
import '../datasources/garage_api_data_source.dart';
import '../datasources/storage_api_data_source.dart';

@LazySingleton(as: GarageRepository)
class GarageRepositoryImpl implements GarageRepository {
  final GarageApiDataSource dataSource;
  final StorageApiDataSource storageDataSource;
  final CarImageService imageService;

  GarageRepositoryImpl(this.dataSource, this.storageDataSource, this.imageService);

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
  Future<Either<Failure, CarEntity>> addCar(CreateCarParams params) async {
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

  // ── Cover image upload ────────────────────────────────────────────────────

  @override
  Future<Either<Failure, UploadUrlResult>> getCoverUploadUrl(
      String carId) async {
    try {
      final model = await storageDataSource.getCoverUploadUrl(carId);
      return Right(model.toEntity());
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('getCoverUploadUrl error: $e');
      return const Left(UnknownFailure('Failed to get upload URL.'));
    }
  }

  @override
  Future<Either<Failure, void>> saveCoverUrl(
      String carId, String finalUrl) async {
    try {
      await dataSource.saveCoverUrl(carId, finalUrl);
      return const Right(null);
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 403) return const Left(NotCarOwnerFailure());
      if (e.statusCode == 404) return const Left(CarNotFoundFailure());
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('saveCoverUrl error: $e');
      return const Left(UnknownFailure('Failed to save cover image.'));
    }
  }

  // ── Gallery upload ────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, UploadUrlResult>> getGalleryUploadUrl(
      String carId) async {
    try {
      final model = await storageDataSource.getGalleryUploadUrl(carId);
      return Right(model.toEntity());
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('getGalleryUploadUrl error: $e');
      return const Left(UnknownFailure('Failed to get upload URL.'));
    }
  }

  @override
  Future<Either<Failure, void>> saveGalleryUrls(
      String carId, List<String> urls) async {
    try {
      await dataSource.saveGalleryUrls(carId, urls);
      return const Right(null);
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 403) return const Left(NotCarOwnerFailure());
      if (e.statusCode == 404) return const Left(CarNotFoundFailure());
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('saveGalleryUrls error: $e');
      return const Left(UnknownFailure('Failed to save gallery.'));
    }
  }

  // ── Image deletion (DB + R2) ──────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> deleteGalleryImages(
      String carId, List<String> urls) async {
    if (urls.isEmpty) return const Right(null);
    try {
      await dataSource.deleteGalleryImages(carId, urls);
      return const Right(null);
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 403) return const Left(NotCarOwnerFailure());
      if (e.statusCode == 404) return const Left(CarNotFoundFailure());
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('deleteGalleryImages error: $e');
      return const Left(UnknownFailure('Failed to delete gallery photos.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCoverImage(
      String carId, String url) async {
    try {
      await dataSource.deleteCoverImage(carId, url);
      return const Right(null);
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ApiException catch (e) {
      if (e.statusCode == 403) return const Left(NotCarOwnerFailure());
      if (e.statusCode == 404) return const Left(CarNotFoundFailure());
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('deleteCoverImage error: $e');
      return const Left(UnknownFailure('Failed to delete cover photo.'));
    }
  }

  // ── Modifications ─────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, CarModificationEntity>> addModification(
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
  Future<Either<Failure, CarModificationEntity>> patchModification(
    String carId,
    String modId,
    ModPatchParams params,
  ) async {
    try {
      final model =
          await dataSource.patchModification(carId, modId, params.toJson());
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
      debugPrint('patchModification error: $e');
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

  // ── Modification media upload ──────────────────────────────────────────────

  @override
  Future<Either<Failure, ModUploadUrlsResult>> getModificationUploadUrls(
    String carId,
    String modId,
    List<ModUploadRequest> files,
  ) async {
    try {
      final model = await storageDataSource.getModificationUploadUrls(
        carId,
        modId,
        files.map((f) => f.toJson().cast<String, String>()).toList(),
      );
      return Right(model.toEntity());
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } on UnauthenticatedException catch (e) {
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('getModificationUploadUrls error: $e');
      return const Left(UnknownFailure('Failed to get upload URLs.'));
    }
  }

  // ── R2 upload ─────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> uploadFileToR2(
    String uploadUrl,
    Uint8List bytes, {
    String contentType = 'image/webp',
  }) async {
    try {
      await imageService.uploadToR2(uploadUrl, bytes, contentType: contentType);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('uploadFileToR2 error: $e');
      return const Left(UnknownFailure('Upload failed.'));
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
  Future<Either<Failure, List<CarDistanceUnitEntity>>>
      getDistanceUnits() async {
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
  Future<Either<Failure, List<CarStatusOptionEntity>>>
      getStatusOptions() async {
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
  Future<Either<Failure, List<CarModCategoryEntity>>>
      getModCategories() async {
    try {
      final models = await dataSource.getModCategories();
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } catch (e) {
      return const Left(UnknownFailure('Failed to load mod categories.'));
    }
  }

  @override
  Future<Either<Failure, List<CarFuelTypeOptionEntity>>>
      getFuelTypeOptions() async {
    try {
      final models = await dataSource.getFuelTypeOptions();
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException {
      return const Left(NetworkFailure('No internet connection.'));
    } catch (e) {
      return const Left(UnknownFailure('Failed to load fuel type options.'));
    }
  }
}
