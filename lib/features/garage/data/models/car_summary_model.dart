import '../../domain/entities/car_summary.dart';
import 'car_status_option_model.dart';

class CarSummaryModel {
  final String id;
  final String brand;
  final String model;
  final String? coverImagePath;
  final CarStatusOptionModel? status;

  const CarSummaryModel({
    required this.id,
    required this.brand,
    required this.model,
    this.coverImagePath,
    this.status,
  });

  factory CarSummaryModel.fromJson(Map<String, dynamic> json) {
    return CarSummaryModel(
      id: json['id'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      coverImagePath: json['cover_image_url'] as String?,
      status: json['status'] != null
          ? CarStatusOptionModel.fromJson(json['status'] as Map<String, dynamic>)
          : null,
    );
  }

  CarSummaryEntity toEntity() {
    return CarSummaryEntity(
      id: id,
      brand: brand,
      model: model,
      coverImagePath: coverImagePath,
      status: status?.toEntity(),
    );
  }
}
