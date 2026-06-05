import 'package:equatable/equatable.dart';

import 'car_status_option.dart';

class CarSummaryEntity extends Equatable {
  final String id;
  final String brand;
  final String model;
  final String? coverImageUrl;
  final CarStatusOptionEntity? status;

  const CarSummaryEntity({
    required this.id,
    required this.brand,
    required this.model,
    this.coverImageUrl,
    this.status,
  });

  @override
  List<Object?> get props => [id, brand, model, coverImageUrl, status];
}
