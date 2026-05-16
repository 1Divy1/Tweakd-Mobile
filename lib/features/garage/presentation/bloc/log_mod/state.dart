import 'package:equatable/equatable.dart';

import '../../../domain/entities/car_modification.dart';
import '../../../domain/entities/reference_data.dart';

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
  final String message;

  const LogModCategoriesError({required this.message});

  @override
  List<Object?> get props => [message];
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
  final String message;
  final List<CarModCategoryEntity> categories;

  const LogModError({required this.message, required this.categories});

  @override
  List<Object?> get props => [message, categories];
}
