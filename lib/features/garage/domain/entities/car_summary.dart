import 'package:equatable/equatable.dart';

import 'car_status_option.dart';

class CarSummaryEntity extends Equatable {
  final String id;
  final String brand;
  final String model;

  /// Canonical storage path. Resolve to a signed URL before display.
  final String? coverImagePath;
  final CarStatusOptionEntity? status;

  const CarSummaryEntity({
    required this.id,
    required this.brand,
    required this.model,
    this.coverImagePath,
    this.status,
  });

  @override
  List<Object?> get props => [id, brand, model, coverImagePath, status];
}
