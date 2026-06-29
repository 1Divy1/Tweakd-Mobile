import 'package:equatable/equatable.dart';

import '../../../domain/entities/car.dart';
import '../../../domain/entities/car_status_option.dart';
import '../../../domain/entities/reference_data.dart';
import '../../utils/garage_error_mapper.dart';

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

  /// In-flight phase; the UI maps it to a localized label.
  final AddCarPhase phase;

  const AddCarSubmitting({required this.refData, required this.phase});

  @override
  List<Object?> get props => [refData, phase];
}

class AddCarSuccess extends AddCarState {
  final CarEntity car;
  const AddCarSuccess(this.car);

  @override
  List<Object?> get props => [car];
}

class AddCarError extends AddCarState {
  final GarageErrorCode code;
  final AddCarRefDataLoaded refData;

  const AddCarError({required this.code, required this.refData});

  @override
  List<Object?> get props => [code, refData];
}

class AddCarRefDataError extends AddCarState {
  final GarageErrorCode code;
  const AddCarRefDataError({required this.code});

  @override
  List<Object?> get props => [code];
}
