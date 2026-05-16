import 'package:equatable/equatable.dart';

import '../../domain/entities/garage.dart';

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
  final bool isDeleting;

  const GarageLoaded({required this.garage, this.isDeleting = false});

  GarageLoaded copyWith({GarageEntity? garage, bool? isDeleting}) {
    return GarageLoaded(
      garage: garage ?? this.garage,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  @override
  List<Object?> get props => [garage, isDeleting];
}

class GarageError extends GarageState {
  final String message;

  const GarageError({required this.message});

  @override
  List<Object?> get props => [message];
}
