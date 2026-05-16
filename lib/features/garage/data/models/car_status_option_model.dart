import '../../domain/entities/car_status_option.dart';

class CarStatusOptionModel {
  final String id;
  final String type;

  const CarStatusOptionModel({required this.id, required this.type});

  factory CarStatusOptionModel.fromJson(Map<String, dynamic> json) {
    return CarStatusOptionModel(
      id: json['id'] as String,
      type: json['type'] as String,
    );
  }

  CarStatusOptionEntity toEntity() {
    return CarStatusOptionEntity(id: id, type: type);
  }
}
