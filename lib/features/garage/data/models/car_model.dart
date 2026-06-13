import '../../domain/entities/car.dart';
import 'car_modification_model.dart';
import 'car_status_option_model.dart';

class CarModel {
  final String id;
  final String garageId;
  final String brandId;
  final String brandName;
  final String modelId;
  final String modelName;
  final String drivetrainId;
  final String drivetrainName;
  final String colorId;
  final String colorName;
  final String colorCode;
  final String mileageUnitId;
  final String mileageUnitName;
  final String fuelTypeId;
  final String fuelTypeName;
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
  final String? coverImageUrl;
  final List<String> galleryUrls;
  final DateTime? createdAt;
  final CarStatusOptionModel status;
  final List<CarModificationModel> modifications;

  const CarModel({
    required this.id,
    required this.garageId,
    required this.brandId,
    required this.brandName,
    required this.modelId,
    required this.modelName,
    required this.drivetrainId,
    required this.drivetrainName,
    required this.colorId,
    required this.colorName,
    required this.colorCode,
    required this.mileageUnitId,
    required this.mileageUnitName,
    required this.fuelTypeId,
    required this.fuelTypeName,
    required this.year,
    required this.horsepower,
    required this.torque,
    required this.weight,
    required this.engineDisplacement,
    required this.status,
    required this.modifications,
    this.mileage,
    this.zeroToOneHundred,
    this.chassisCode,
    this.modelCode,
    this.engineCode,
    this.coverImageUrl,
    this.galleryUrls = const [],
    this.createdAt,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id'] as String,
      garageId: json['garage_id'] as String,
      brandId: json['brand_id'] as String,
      brandName: json['brand_name'] as String,
      modelId: json['model_id'] as String,
      modelName: json['model_name'] as String,
      drivetrainId: json['drivetrain_id'] as String,
      drivetrainName: json['drivetrain_name'] as String,
      colorId: json['color_id'] as String,
      colorName: json['color_name'] as String,
      colorCode: json['color_code'] as String,
      mileageUnitId: json['mileage_unit_id'] as String,
      mileageUnitName: json['mileage_unit_name'] as String,
      fuelTypeId: json['fuel_type_id'] as String,
      fuelTypeName: json['fuel_type_name'] as String,
      mileage: json['mileage'] as int?,
      year: json['year'] as int,
      horsepower: json['horsepower'] as int,
      torque: json['torque'] as int,
      weight: json['weight'] as int,
      engineDisplacement: (json['engine_displacement'] as num).toDouble(),
      zeroToOneHundred: (json['zero_to_one_hundred'] as num?)?.toDouble(),
      chassisCode: json['chassis_code'] as String?,
      modelCode: json['model_code'] as String?,
      engineCode: json['engine_code'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      galleryUrls: (json['gallery_urls'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      status: CarStatusOptionModel(
        id: json['status_id'] as String,
        type: json['status_name'] as String,
      ),
      modifications: (json['modifications'] as List<dynamic>)
          .map((e) => CarModificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  CarEntity toEntity() {
    return CarEntity(
      id: id,
      garageId: garageId,
      brandId: brandId,
      brandName: brandName,
      modelId: modelId,
      modelName: modelName,
      drivetrainId: drivetrainId,
      drivetrainName: drivetrainName,
      colorId: colorId,
      colorName: colorName,
      colorCode: colorCode,
      mileageUnitId: mileageUnitId,
      mileageUnitName: mileageUnitName,
      fuelTypeId: fuelTypeId,
      fuelTypeName: fuelTypeName,
      mileage: mileage,
      year: year,
      horsepower: horsepower,
      torque: torque,
      weight: weight,
      engineDisplacement: engineDisplacement,
      zeroToOneHundred: zeroToOneHundred,
      chassisCode: chassisCode,
      modelCode: modelCode,
      engineCode: engineCode,
      coverImageUrl: coverImageUrl,
      galleryUrls: galleryUrls,
      createdAt: createdAt,
      status: status.toEntity(),
      modifications: modifications.map((m) => m.toEntity()).toList(),
    );
  }
}
