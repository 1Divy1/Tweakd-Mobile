import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../../../core/error/base_failures.dart';
import '../entities/car.dart';
import '../entities/car_modification.dart';
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
  Future<Either<Failure, CarEntity>> addCar(CreateCarParams params);
  Future<Either<Failure, CarEntity>> updateCar(
    String carId,
    CarRequestParams params,
  );
  Future<Either<Failure, void>> deleteCar(String carId);

  // ── Cover image upload (3-step) ───────────────────────────────────────────
  Future<Either<Failure, UploadUrlResult>> getCoverUploadUrl(String carId);
  Future<Either<Failure, void>> saveCoverUrl(String carId, String finalUrl);

  // ── Gallery upload (3-step per photo, then PATCH with full list) ──────────
  Future<Either<Failure, UploadUrlResult>> getGalleryUploadUrl(String carId);
  Future<Either<Failure, void>> saveGalleryUrls(
      String carId, List<String> urls);

  // ── Modifications ─────────────────────────────────────────────────────────
  Future<Either<Failure, CarModificationEntity>> addModification(
    String carId,
    ModRequestParams params,
  );

  /// PATCH endpoint — sends only the fields that changed. Handles both text
  /// updates and media add/remove in a single call.
  Future<Either<Failure, CarModificationEntity>> patchModification(
    String carId,
    String modId,
    ModPatchParams params,
  );

  Future<Either<Failure, void>> deleteModification(String carId, String modId);

  // ── Modification media upload (batch presigned URLs, then PATCH) ──────────
  Future<Either<Failure, ModUploadUrlsResult>> getModificationUploadUrls(
    String carId,
    String modId,
    List<ModUploadRequest> files,
  );

  // ── R2 upload (step 2 — no JWT, PUT directly to Cloudflare) ───────────────
  Future<Either<Failure, void>> uploadFileToR2(
    String uploadUrl,
    Uint8List bytes, {
    String contentType = 'image/webp',
  });

  // ── Reference data ────────────────────────────────────────────────────────
  Future<Either<Failure, List<CarBrandEntity>>> getBrands();
  Future<Either<Failure, List<CarModelEntity>>> getModelsByBrand(String brandId);
  Future<Either<Failure, List<CarDrivetrainEntity>>> getDrivetrains();
  Future<Either<Failure, List<CarColorEntity>>> getColors();
  Future<Either<Failure, List<CarDistanceUnitEntity>>> getDistanceUnits();
  Future<Either<Failure, List<CarStatusOptionEntity>>> getStatusOptions();
  Future<Either<Failure, List<CarModCategoryEntity>>> getModCategories();
  Future<Either<Failure, List<CarFuelTypeOptionEntity>>> getFuelTypeOptions();
}

// ── Request param classes ─────────────────────────────────────────────────────

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
  final String? fuelTypeId;
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
    this.fuelTypeId,
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
        if (fuelTypeId != null) 'fuel_type_id': fuelTypeId,
        'status_id': statusId,
      };
}

class ModRequestParams {
  final String categoryId;
  final String title;
  final String? description;
  final DateTime installationDate;
  final double? price;
  final int? mileageAtInstall;

  const ModRequestParams({
    required this.categoryId,
    required this.title,
    this.description,
    required this.installationDate,
    this.price,
    this.mileageAtInstall,
  });

  Map<String, dynamic> toJson() => {
        'category_id': categoryId,
        'title': title,
        if (description != null && description!.isNotEmpty)
          'description': description,
        'installation_date': installationDate.toUtc().toIso8601String(),
        if (price != null) 'price': price,
        if (mileageAtInstall != null) 'mileage_at_install': mileageAtInstall,
      };
}

/// Partial update for a modification. Only non-null fields are included in the
/// JSON payload sent to `PATCH /garage/cars/{carId}/modifications/{modId}`.
class ModPatchParams {
  final String? title;
  final String? description;
  final DateTime? installationDate;
  final double? price;
  final int? mileageAtInstall;
  final List<ModMediaInput>? addMedia;
  final List<String>? removeMediaUrls;

  const ModPatchParams({
    this.title,
    this.description,
    this.installationDate,
    this.price,
    this.mileageAtInstall,
    this.addMedia,
    this.removeMediaUrls,
  });

  Map<String, dynamic> toJson() => {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (installationDate != null)
          'installation_date': installationDate!.toUtc().toIso8601String(),
        if (price != null) 'price': price,
        if (mileageAtInstall != null) 'mileage_at_install': mileageAtInstall,
        if (addMedia != null && addMedia!.isNotEmpty)
          'add_media': addMedia!.map((m) => m.toJson()).toList(),
        if (removeMediaUrls != null && removeMediaUrls!.isNotEmpty)
          'remove_media_urls': removeMediaUrls,
      };
}

/// A single media item to add to a modification.
/// [phase] must be 'before' or 'after' (lowercase).
class ModMediaInput {
  final String url;
  final String phase;

  const ModMediaInput({required this.url, required this.phase});

  Map<String, dynamic> toJson() => {'url': url, 'phase': phase};
}

/// One file in a batch upload-urls request.
/// [phase] must be 'BEFORE' or 'AFTER'; [format] must be 'WEBP' or 'MP4'.
class ModUploadRequest {
  final String phase;
  final String format;

  const ModUploadRequest({required this.phase, required this.format});

  Map<String, dynamic> toJson() => {'phase': phase, 'format': format};
}

/// Single-shot car creation payload.
class CreateCarParams {
  final CarRequestParams car;
  final List<ModRequestParams> modifications;

  const CreateCarParams({
    required this.car,
    required this.modifications,
  });

  Map<String, dynamic> toJson() => {
        'car': car.toJson(),
        'modifications': modifications.map((m) => m.toJson()).toList(),
      };
}
