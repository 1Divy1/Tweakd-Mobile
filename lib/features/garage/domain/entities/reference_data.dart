import 'package:equatable/equatable.dart';

import 'car_status_option.dart';

class CarBrandEntity extends Equatable {
  final String id;
  final String name;

  const CarBrandEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class CarModelEntity extends Equatable {
  final String id;
  final String brandId;
  final String model;

  const CarModelEntity({
    required this.id,
    required this.brandId,
    required this.model,
  });

  @override
  List<Object?> get props => [id, brandId, model];
}

class CarDrivetrainEntity extends Equatable {
  final String id;
  final String name;

  const CarDrivetrainEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class CarColorEntity extends Equatable {
  final String id;
  final String name;
  final String colorCode;

  const CarColorEntity({
    required this.id,
    required this.name,
    required this.colorCode,
  });

  @override
  List<Object?> get props => [id, name, colorCode];
}

class CarDistanceUnitEntity extends Equatable {
  final String id;
  final String name;

  const CarDistanceUnitEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class CarModCategoryEntity extends Equatable {
  final String id;
  final String modName;

  const CarModCategoryEntity({required this.id, required this.modName});

  @override
  List<Object?> get props => [id, modName];
}

class CarFuelTypeOptionEntity extends Equatable {
  final String id;
  final String name;

  const CarFuelTypeOptionEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class GarageReferenceData extends Equatable {
  final List<CarBrandEntity> brands;
  final List<CarDrivetrainEntity> drivetrains;
  final List<CarColorEntity> colors;
  final List<CarDistanceUnitEntity> distanceUnits;
  final List<CarStatusOptionEntity> statusOptions;

  const GarageReferenceData({
    required this.brands,
    required this.drivetrains,
    required this.colors,
    required this.distanceUnits,
    required this.statusOptions,
  });

  @override
  List<Object?> get props => [brands, drivetrains, colors, distanceUnits, statusOptions];
}

