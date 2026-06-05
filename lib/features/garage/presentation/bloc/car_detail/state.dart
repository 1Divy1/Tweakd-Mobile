import 'package:equatable/equatable.dart';

import '../../../domain/entities/car.dart';

abstract class CarDetailState extends Equatable {
  const CarDetailState();

  @override
  List<Object?> get props => [];
}

class CarDetailLoading extends CarDetailState {
  const CarDetailLoading();
}

class CarDetailLoaded extends CarDetailState {
  final CarEntity car;
  final bool isDeleting;

  const CarDetailLoaded({
    required this.car,
    this.isDeleting = false,
  });

  CarDetailLoaded copyWith({
    CarEntity? car,
    bool? isDeleting,
  }) {
    return CarDetailLoaded(
      car: car ?? this.car,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  @override
  List<Object?> get props => [car, isDeleting];
}

class CarDetailError extends CarDetailState {
  final String message;
  const CarDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}

class CarDetailDeleted extends CarDetailState {
  const CarDetailDeleted();
}
