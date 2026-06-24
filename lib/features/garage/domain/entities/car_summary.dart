import 'package:equatable/equatable.dart';

import 'car_image_ref.dart';
import 'car_status_option.dart';

class CarSummaryEntity extends Equatable {
  final String id;
  final String brand;
  final String model;
  final CarImageRef? coverImage;
  final CarStatusOptionEntity? status;

  const CarSummaryEntity({
    required this.id,
    required this.brand,
    required this.model,
    this.coverImage,
    this.status,
  });

  @override
  List<Object?> get props => [id, brand, model, coverImage, status];
}
