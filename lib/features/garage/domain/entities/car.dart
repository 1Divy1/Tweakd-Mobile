import 'package:equatable/equatable.dart';

import '../../../../core/shared/entities/image_ref.dart';
import 'car_modification.dart';
import 'car_status_option.dart';

class CarEntity extends Equatable {
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
  final String? story;
  final ImageRef? coverImage;
  final List<ImageRef> gallery;
  final DateTime? createdAt;
  final CarStatusOptionEntity status;
  final List<CarModificationEntity> modifications;

  const CarEntity({
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
    required this.year,
    required this.horsepower,
    required this.torque,
    required this.weight,
    required this.engineDisplacement,
    required this.fuelTypeId,
    required this.fuelTypeName,
    required this.status,
    required this.modifications,
    this.mileage,
    this.zeroToOneHundred,
    this.chassisCode,
    this.modelCode,
    this.engineCode,
    this.story,
    this.coverImage,
    this.gallery = const [],
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        garageId,
        brandId,
        brandName,
        modelId,
        modelName,
        drivetrainId,
        drivetrainName,
        colorId,
        colorName,
        colorCode,
        mileageUnitId,
        mileageUnitName,
        mileage,
        year,
        horsepower,
        torque,
        weight,
        engineDisplacement,
        zeroToOneHundred,
        chassisCode,
        modelCode,
        engineCode,
        story,
        coverImage,
        gallery,
        createdAt,
        status,
        modifications,
        fuelTypeId,
        fuelTypeName,
      ];

  CarEntity copyWith({
    String? id,
    String? garageId,
    String? brandId,
    String? brandName,
    String? modelId,
    String? modelName,
    String? drivetrainId,
    String? drivetrainName,
    String? colorId,
    String? colorName,
    String? colorCode,
    String? mileageUnitId,
    String? mileageUnitName,
    String? fuelTypeId,
    String? fuelTypeName,
    int? mileage,
    int? year,
    int? horsepower,
    int? torque,
    int? weight,
    double? engineDisplacement,
    double? zeroToOneHundred,
    String? chassisCode,
    String? modelCode,
    String? engineCode,
    String? story,
    ImageRef? coverImage,
    List<ImageRef>? gallery,
    DateTime? createdAt,
    CarStatusOptionEntity? status,
    List<CarModificationEntity>? modifications,
  }) {
    return CarEntity(
      id: id ?? this.id,
      garageId: garageId ?? this.garageId,
      brandId: brandId ?? this.brandId,
      brandName: brandName ?? this.brandName,
      modelId: modelId ?? this.modelId,
      modelName: modelName ?? this.modelName,
      drivetrainId: drivetrainId ?? this.drivetrainId,
      drivetrainName: drivetrainName ?? this.drivetrainName,
      colorId: colorId ?? this.colorId,
      colorName: colorName ?? this.colorName,
      colorCode: colorCode ?? this.colorCode,
      mileageUnitId: mileageUnitId ?? this.mileageUnitId,
      mileageUnitName: mileageUnitName ?? this.mileageUnitName,
      fuelTypeId: fuelTypeId ?? this.fuelTypeId,
      fuelTypeName: fuelTypeName ?? this.fuelTypeName,
      mileage: mileage ?? this.mileage,
      year: year ?? this.year,
      horsepower: horsepower ?? this.horsepower,
      torque: torque ?? this.torque,
      weight: weight ?? this.weight,
      engineDisplacement: engineDisplacement ?? this.engineDisplacement,
      zeroToOneHundred: zeroToOneHundred ?? this.zeroToOneHundred,
      chassisCode: chassisCode ?? this.chassisCode,
      modelCode: modelCode ?? this.modelCode,
      engineCode: engineCode ?? this.engineCode,
      story: story ?? this.story,
      coverImage: coverImage ?? this.coverImage,
      gallery: gallery ?? this.gallery,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      modifications: modifications ?? this.modifications,
    );
  }
}
