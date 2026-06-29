import 'package:equatable/equatable.dart';

import '../../../domain/entities/car_modification.dart';
import '../../../domain/entities/reference_data.dart';
import '../../utils/garage_error_mapper.dart';

abstract class LogModState extends Equatable {
  const LogModState();

  @override
  List<Object?> get props => [];
}

class LogModInitial extends LogModState {
  const LogModInitial();
}

class LogModCategoriesLoading extends LogModState {
  const LogModCategoriesLoading();
}

class LogModCategoriesLoaded extends LogModState {
  final List<CarModCategoryEntity> categories;

  const LogModCategoriesLoaded({required this.categories});

  @override
  List<Object?> get props => [categories];
}

class LogModCategoriesError extends LogModState {
  final GarageErrorCode code;

  const LogModCategoriesError({required this.code});

  @override
  List<Object?> get props => [code];
}

class LogModSubmitting extends LogModState {
  final List<CarModCategoryEntity> categories;

  const LogModSubmitting({required this.categories});

  @override
  List<Object?> get props => [categories];
}

class LogModSuccess extends LogModState {
  final CarModificationEntity mod;

  const LogModSuccess(this.mod);

  @override
  List<Object?> get props => [mod];
}

class LogModError extends LogModState {
  final GarageErrorCode code;
  final List<CarModCategoryEntity> categories;

  const LogModError({required this.code, required this.categories});

  @override
  List<Object?> get props => [code, categories];
}
