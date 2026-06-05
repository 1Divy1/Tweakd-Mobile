import 'car_model.dart';
import 'car_modification_model.dart';

/// Response from POST /garage/cars — a full CarDto with all specs and
/// modifications, but without media URLs (those are uploaded separately).
class CreateCarResponseModel {
  final CarModel car;

  const CreateCarResponseModel({required this.car});

  factory CreateCarResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateCarResponseModel(
      car: CarModel.fromJson(json['car'] as Map<String, dynamic>),
    );
  }
}

/// Response from POST /garage/cars/{carId}/modifications — the created
/// modification DTO. Media is added separately via the 3-step upload flow.
class AddModificationResponseModel {
  final CarModificationModel modification;

  const AddModificationResponseModel({required this.modification});

  factory AddModificationResponseModel.fromJson(Map<String, dynamic> json) {
    return AddModificationResponseModel(
      modification: CarModificationModel.fromJson(
          json['modification'] as Map<String, dynamic>),
    );
  }
}
