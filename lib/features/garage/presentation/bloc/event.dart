import 'package:equatable/equatable.dart';

abstract class GarageEvent extends Equatable {
  const GarageEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyGarage extends GarageEvent {
  const LoadMyGarage();
}

class LoadGarageByUsername extends GarageEvent {
  final String username;

  const LoadGarageByUsername(this.username);

  @override
  List<Object?> get props => [username];
}

class DeleteCar extends GarageEvent {
  final String carId;

  const DeleteCar(this.carId);

  @override
  List<Object?> get props => [carId];
}
