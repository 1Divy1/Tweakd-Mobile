import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../../../core/error/base_failures.dart';
import '../entities/car.dart';
import '../entities/car_modification.dart';
import '../entities/car_share.dart';
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
  /// Points the car at the uploaded cover by its R2 [key] (from the upload-url
  /// response). The backend builds the display url on read.
  Future<Either<Failure, void>> saveCoverKey(String carId, String key);

  // ── Gallery upload (3-step per photo, then PATCH with full list) ──────────
  Future<Either<Failure, UploadUrlResult>> getGalleryUploadUrl(String carId);
  /// Persists the full desired gallery state as a list of R2 [keys].
  Future<Either<Failure, void>> saveGalleryKeys(
      String carId, List<String> keys);

  // ── Image deletion (DB + R2) ──────────────────────────────────────────────
  /// Deletes the given gallery photos (by R2 [keys]) from both the DB list and
  /// R2 storage.
  Future<Either<Failure, void>> deleteGalleryImages(
      String carId, List<String> keys);

  /// Deletes the car's current cover object from R2 (used when replacing it).
  /// The backend resolves the cover from the car id — no key needed.
  Future<Either<Failure, void>> deleteCoverImage(String carId);

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

  // ── Share links (owner only) ──────────────────────────────────────────────
  /// Returns the car's live share link, minting one on the first call.
  Future<Either<Failure, CarShareEntity>> ensureShareLink(String carId);

  /// Pauses or resumes the link. The code never changes, so a printed sticker
  /// survives both.
  Future<Either<Failure, CarShareEntity>> setShareLinkEnabled(
    String carId,
    bool enabled,
  );

  /// The share URL as a print-ready QR, as raw SVG source.
  Future<Either<Failure, String>> getShareQrSvg(String carId);

  // ── Resolving an incoming share code ──────────────────────────────────────
  /// Turns a scanned or tapped code into the car it points at. [source] is the
  /// `?s=` tag the link carried, so the visit is counted as what it was.
  Future<Either<Failure, CarShareResolutionEntity>> resolveShareCode(
    String code, {
    String? source,
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
  final int? mileage;
  final int year;
  final int horsepower;
  final int torque;
  final int weight;
  final double engineDisplacement;
  final double? zeroToOneHundred;
  final String? chassisCode;
  final String? modelCode;
  final String? engineCode;
  final String? fuelTypeId;
  final String? story;
  final String statusId;

  const CarRequestParams({
    required this.brandId,
    required this.modelId,
    required this.drivetrainId,
    required this.colorId,
    required this.mileageUnitId,
    this.mileage,
    required this.year,
    required this.horsepower,
    required this.torque,
    required this.weight,
    required this.engineDisplacement,
    this.zeroToOneHundred,
    this.chassisCode,
    this.modelCode,
    this.engineCode,
    this.fuelTypeId,
    this.story,
    required this.statusId,
  });

  Map<String, dynamic> toJson() => {
        'brand_id': brandId,
        'model_id': modelId,
        'drivetrain_id': drivetrainId,
        'color_id': colorId,
        'mileage_unit_id': mileageUnitId,
        if (mileage != null) 'mileage': mileage,
        'year': year,
        'horsepower': horsepower,
        'torque': torque,
        'weight': weight,
        'engine_displacement': engineDisplacement,
        if (zeroToOneHundred != null) 'zero_to_one_hundred': zeroToOneHundred,
        if (chassisCode != null && chassisCode!.isNotEmpty)
          'chassis_code': chassisCode,
        if (modelCode != null && modelCode!.isNotEmpty)
          'model_code': modelCode,
        if (engineCode != null && engineCode!.isNotEmpty)
          'engine_code': engineCode,
        if (fuelTypeId != null) 'fuel_type_id': fuelTypeId,
        if (story != null && story!.isNotEmpty) 'story': story,
        'status_id': statusId,
      };
}

class ModRequestParams {
  final String categoryId;
  final String title;
  final String? description;
  final DateTime installationDate;
  final double? price;

  /// Whether other users may see [price]. False keeps it to the owner — a price
  /// is recorded for one's own expense tracking unless deliberately published.
  final bool isPricePublic;
  final int? mileageAtInstall;

  const ModRequestParams({
    required this.categoryId,
    required this.title,
    this.description,
    required this.installationDate,
    this.price,
    this.isPricePublic = false,
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

/// Partial update for a modification. Only non-null fields are included in the
/// JSON payload sent to `PATCH /garage/cars/{carId}/modifications/{modId}`.
class ModPatchParams {
  final String? title;
  final String? description;
  final DateTime? installationDate;
  final double? price;
  final bool? isPricePublic;
  final int? mileageAtInstall;
  final List<ModMediaInput>? addMedia;
  final List<String>? removeMediaKeys;

  const ModPatchParams({
    this.title,
    this.description,
    this.installationDate,
    this.price,
    this.isPricePublic,
    this.mileageAtInstall,
    this.addMedia,
    this.removeMediaKeys,
  });

  Map<String, dynamic> toJson() => {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (installationDate != null)
          'installation_date': installationDate!.toUtc().toIso8601String(),
        if (price != null) 'price': price,
        if (isPricePublic != null) 'is_price_public': isPricePublic,
        if (mileageAtInstall != null) 'mileage_at_install': mileageAtInstall,
        if (addMedia != null && addMedia!.isNotEmpty)
          'add_media': addMedia!.map((m) => m.toJson()).toList(),
        if (removeMediaKeys != null && removeMediaKeys!.isNotEmpty)
          'remove_media_keys': removeMediaKeys,
      };
}

/// A single media item to add to a modification, referenced by its R2 [key]
/// (from the upload-urls response). [phase] must be 'before' or 'after'.
class ModMediaInput {
  final String key;
  final String phase;

  const ModMediaInput({required this.key, required this.phase});

  Map<String, dynamic> toJson() => {'key': key, 'phase': phase};
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
