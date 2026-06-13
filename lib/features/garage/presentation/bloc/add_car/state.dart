import 'package:equatable/equatable.dart';

import '../../../domain/entities/car.dart';
import '../../../domain/entities/car_status_option.dart';
import '../../../domain/entities/reference_data.dart';

abstract class AddCarState extends Equatable {
  const AddCarState();

  @override
  List<Object?> get props => [];
}

class AddCarInitial extends AddCarState {
  const AddCarInitial();
}

class AddCarRefDataLoading extends AddCarState {
  const AddCarRefDataLoading();
}

class AddCarRefDataLoaded extends AddCarState {
  final List<CarBrandEntity> brands;
  final List<CarModelEntity> models;
  final List<CarDrivetrainEntity> drivetrains;
  final List<CarColorEntity> colors;
  final List<CarDistanceUnitEntity> distanceUnits;
  final List<CarStatusOptionEntity> statusOptions;
  final List<CarModCategoryEntity> modCategories;
  final List<CarFuelTypeOptionEntity> fuelTypeOptions;
  final bool modelsLoading;

  const AddCarRefDataLoaded({
    required this.brands,
    this.models = const [],
    required this.drivetrains,
    required this.colors,
    required this.distanceUnits,
    required this.statusOptions,
    required this.modCategories,
    required this.fuelTypeOptions,
    this.modelsLoading = false,
  });

  AddCarRefDataLoaded copyWith({
    List<CarModelEntity>? models,
    bool? modelsLoading,
  }) {
    return AddCarRefDataLoaded(
      brands: brands,
      models: models ?? this.models,
      drivetrains: drivetrains,
      colors: colors,
      distanceUnits: distanceUnits,
      statusOptions: statusOptions,
      modCategories: modCategories,
      fuelTypeOptions: fuelTypeOptions,
      modelsLoading: modelsLoading ?? this.modelsLoading,
    );
  }

  @override
  List<Object?> get props => [
        brands,
        models,
        drivetrains,
        colors,
        distanceUnits,
        statusOptions,
        modCategories,
        fuelTypeOptions,
        modelsLoading,
      ];
}

class AddCarSubmitting extends AddCarState {
  final AddCarRefDataLoaded refData;

  /// Human-readable phase, e.g. "Creating machine…", "Uploading photos…".
  final String statusLabel;

  const AddCarSubmitting({required this.refData, required this.statusLabel});

  @override
  List<Object?> get props => [refData, statusLabel];
}

class AddCarSuccess extends AddCarState {
  final CarEntity car;
  const AddCarSuccess(this.car);

  @override
  List<Object?> get props => [car];
}

class AddCarError extends AddCarState {
  final String message;
  final AddCarRefDataLoaded refData;

  const AddCarError({required this.message, required this.refData});

  @override
  List<Object?> get props => [message, refData];
}

class AddCarRefDataError extends AddCarState {
  final String message;
  const AddCarRefDataError({required this.message});

  @override
  List<Object?> get props => [message];
}
