import 'package:equatable/equatable.dart';

import 'car_summary.dart';

class GarageEntity extends Equatable {
  final String id;
  final String ownerId;
  final DateTime createdAt;
  final List<CarSummaryEntity> cars;

  const GarageEntity({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.cars,
  });

  GarageEntity copyWith({List<CarSummaryEntity>? cars}) {
    return GarageEntity(
      id: id,
      ownerId: ownerId,
      createdAt: createdAt,
      cars: cars ?? this.cars,
    );
  }

  @override
  List<Object?> get props => [id, ownerId, createdAt, cars];
}
