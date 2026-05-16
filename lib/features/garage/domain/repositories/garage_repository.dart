import 'package:dartz/dartz.dart';

import '../../../../core/error/base_failures.dart';
import '../entities/car.dart';
import '../entities/car_image.dart';
import '../entities/car_status_option.dart';
import '../entities/create_car_result.dart';
import '../entities/garage.dart';
import '../entities/reference_data.dart';

abstract class GarageRepository {
  // ── Garage ────────────────────────────────────────────────────────────────
  Future<Either<Failure, GarageEntity>> getMyGarage();
  Future<Either<Failure, GarageEntity>> getGarageByUsername(String username);

  // ── Cars ──────────────────────────────────────────────────────────────────
  Future<Either<Failure, CarEntity>> getCar(String carId);

  /// Single-shot create. Returns the created car plus presigned upload slots;
  /// the caller is responsible for uploading bytes and rolling back via
  /// [deleteCar] on any upload failure.
  Future<Either<Failure, CreateCarResult>> addCar(CreateCarParams params);
  Future<Either<Failure, CarEntity>> updateCar(
    String carId,
    CarRequestParams params,
  );
  Future<Either<Failure, void>> deleteCar(String carId);

  // ── Modifications ─────────────────────────────────────────────────────────
  Future<Either<Failure, AddModificationResult>> addModification(
    String carId,
    ModRequestParams params,
  );
  Future<Either<Failure, void>> updateModification(
    String carId,
    String modId,
    ModRequestParams params,
  );
  Future<Either<Failure, void>> deleteModification(String carId, String modId);

  // ── Gallery images ────────────────────────────────────────────────────────
  Future<Either<Failure, List<CarImageEntity>>> listCarImages(String carId);
  Future<Either<Failure, void>> deleteCarImage(String carId, String imageId);

  /// Resolves a canonical storage path to a short-lived signed download URL.
  Future<Either<Failure, String>> resolveImageUrl(String storagePath);

  // ── Reference data ────────────────────────────────────────────────────────
  Future<Either<Failure, List<CarBrandEntity>>> getBrands();
  Future<Either<Failure, List<CarModelEntity>>> getModelsByBrand(String brandId);
  Future<Either<Failure, List<CarDrivetrainEntity>>> getDrivetrains();
  Future<Either<Failure, List<CarColorEntity>>> getColors();
  Future<Either<Failure, List<CarDistanceUnitEntity>>> getDistanceUnits();
  Future<Either<Failure, List<CarStatusOptionEntity>>> getStatusOptions();
  Future<Either<Failure, List<CarModCategoryEntity>>> getModCategories();
}

// ── Request param classes ─────────────────────────────────────────────────────

/// Car specs for create/update. Image paths are backend-generated and are NOT
/// part of this payload anymore.
class CarRequestParams {
  final String brandId;
  final String modelId;
  final String drivetrainId;
  final String colorId;
  final String mileageUnitId;
  final int year;
  final int horsepower;
  final int torque;
  final int weight;
  final double engineDisplacement;
  final double? zeroToOneHundred;
  final String? chassisCode;
  final String? engineCode;
  final String statusId;

  const CarRequestParams({
    required this.brandId,
    required this.modelId,
    required this.drivetrainId,
    required this.colorId,
    required this.mileageUnitId,
    required this.year,
    required this.horsepower,
    required this.torque,
    required this.weight,
    required this.engineDisplacement,
    this.zeroToOneHundred,
    this.chassisCode,
    this.engineCode,
    required this.statusId,
  });

  Map<String, dynamic> toJson() => {
        'brand_id': brandId,
        'model_id': modelId,
        'drivetrain_id': drivetrainId,
        'color_id': colorId,
        'mileage_unit_id': mileageUnitId,
        'year': year,
        'horsepower': horsepower,
        'torque': torque,
        'weight': weight,
        'engine_displacement': engineDisplacement,
        if (zeroToOneHundred != null) 'zero_to_one_hundred': zeroToOneHundred,
        if (chassisCode != null && chassisCode!.isNotEmpty)
          'chassis_code': chassisCode,
        if (engineCode != null && engineCode!.isNotEmpty)
          'engine_code': engineCode,
        'status_id': statusId,
      };
}

/// Modification details for create/update. Image paths are backend-generated.
class ModRequestParams {
  final String categoryId;
  final String title;
  final String? description;
  final DateTime installationDate;
  final double? price;
  final bool isPricePublic;
  final int? mileageAtInstall;

  const ModRequestParams({
    required this.categoryId,
    required this.title,
    this.description,
    required this.installationDate,
    this.price,
    required this.isPricePublic,
    this.mileageAtInstall,
  });

  Map<String, dynamic> toJson() => {
        'category_id': categoryId,
        'title': title,
        if (description != null && description!.isNotEmpty)
          'description': description,
        'installation_date': installationDate.toUtc().toIso8601String(),
        if (price != null) 'price': price,
        'is_price_public': isPricePublic,
        if (mileageAtInstall != null) 'mileage_at_install': mileageAtInstall,
      };
}

/// Single-shot create payload: the car, its modifications (in order), and how
/// many gallery slots to pre-allocate upload URLs for.
class CreateCarParams {
  final CarRequestParams car;
  final List<ModRequestParams> modifications;
  final int galleryCount;

  const CreateCarParams({
    required this.car,
    required this.modifications,
    required this.galleryCount,
  });

  Map<String, dynamic> toJson() => {
        'car': car.toJson(),
        'modifications': modifications.map((m) => m.toJson()).toList(),
        'gallery_count': galleryCount,
      };
}
