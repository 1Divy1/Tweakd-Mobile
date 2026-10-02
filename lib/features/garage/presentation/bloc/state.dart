import 'package:equatable/equatable.dart';

import '../../domain/entities/garage.dart';
import '../utils/garage_error_mapper.dart';

abstract class GarageState extends Equatable {
  const GarageState();

  @override
  List<Object?> get props => [];
}

class GarageInitial extends GarageState {
  const GarageInitial();
}

class GarageLoading extends GarageState {
  const GarageLoading();
}

class GarageLoaded extends GarageState {
  final GarageEntity garage;

  const GarageLoaded({required this.garage});

  @override
  List<Object?> get props => [garage];
}

class GarageError extends GarageState {
  final GarageErrorCode code;

  const GarageError({required this.code});

  @override
  List<Object?> get props => [code];
}
