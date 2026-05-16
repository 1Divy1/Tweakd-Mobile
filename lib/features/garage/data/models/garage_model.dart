import '../../domain/entities/garage.dart';
import 'car_summary_model.dart';

class GarageModel {
  final String id;
  final String ownerId;
  final DateTime createdAt;
  final List<CarSummaryModel> cars;

  const GarageModel({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.cars,
  });

  factory GarageModel.fromJson(Map<String, dynamic> json) {
    return GarageModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      cars: (json['cars'] as List<dynamic>)
          .map((e) => CarSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  GarageEntity toEntity() {
    return GarageEntity(
      id: id,
      ownerId: ownerId,
      createdAt: createdAt,
      cars: cars.map((c) => c.toEntity()).toList(),
    );
  }
}
