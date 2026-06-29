import 'package:equatable/equatable.dart';

abstract class CarDetailEvent extends Equatable {
  const CarDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadCar extends CarDetailEvent {
  final String carId;
  const LoadCar(this.carId);

  @override
  List<Object?> get props => [carId];
}

class DeleteCarFromDetail extends CarDetailEvent {
  final String carId;
  const DeleteCarFromDetail(this.carId);

  @override
  List<Object?> get props => [carId];
}

/// Removes a gallery photo by its R2 key and persists the updated list to the
/// backend via DELETE /garage/cars/{carId}/gallery.
class DeleteGalleryImage extends CarDetailEvent {
  final String carId;
  final String imageKey;
  const DeleteGalleryImage({required this.carId, required this.imageKey});

  @override
  List<Object?> get props => [carId, imageKey];
}

class DeleteModificationFromDetail extends CarDetailEvent {
  final String carId;
  final String modId;
  const DeleteModificationFromDetail({required this.carId, required this.modId});

  @override
  List<Object?> get props => [carId, modId];
}
