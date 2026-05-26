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

/// Removes a gallery photo by its URL and persists the updated list to the
/// backend via PATCH /garage/cars/{carId}/gallery.
class DeleteGalleryImage extends CarDetailEvent {
  final String carId;
  final String imageUrl;
  const DeleteGalleryImage({required this.carId, required this.imageUrl});

  @override
  List<Object?> get props => [carId, imageUrl];
}

class DeleteModificationFromDetail extends CarDetailEvent {
  final String carId;
  final String modId;
  const DeleteModificationFromDetail({required this.carId, required this.modId});

  @override
  List<Object?> get props => [carId, modId];
}
