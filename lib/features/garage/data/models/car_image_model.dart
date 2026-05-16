import '../../domain/entities/car_image.dart';

class CarImageModel {
  final String id;
  final String storagePath;
  final int displayOrder;
  final DateTime createdAt;

  const CarImageModel({
    required this.id,
    required this.storagePath,
    required this.displayOrder,
    required this.createdAt,
  });

  factory CarImageModel.fromJson(Map<String, dynamic> json) {
    return CarImageModel(
      id: json['id'] as String,
      storagePath: json['storage_path'] as String,
      displayOrder: json['display_order'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  CarImageEntity toEntity() => CarImageEntity(
        id: id,
        storagePath: storagePath,
        displayOrder: displayOrder,
        createdAt: createdAt,
      );
}
