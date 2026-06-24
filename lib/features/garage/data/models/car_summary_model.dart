import '../../domain/entities/car_summary.dart';
import 'car_model.dart';
import 'car_status_option_model.dart';

class CarSummaryModel {
  final String id;
  final String brand;
  final String model;
  final CarImageRefModel? coverImage;
  final CarStatusOptionModel? status;

  const CarSummaryModel({
    required this.id,
    required this.brand,
    required this.model,
    this.coverImage,
    this.status,
  });

  factory CarSummaryModel.fromJson(Map<String, dynamic> json) {
    return CarSummaryModel(
      id: json['id'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      coverImage: json['cover_image'] == null
          ? null
          : CarImageRefModel.fromJson(
              json['cover_image'] as Map<String, dynamic>),
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
      coverImage: coverImage?.toEntity(),
      status: status?.toEntity(),
    );
  }
}
