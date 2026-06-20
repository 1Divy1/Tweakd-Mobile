import '../../../domain/entities/onboarding reference/car_category_entity.dart';

class CarCategoryModel {
  final String id;
  final String name;

  const CarCategoryModel({required this.id, required this.name});

  factory CarCategoryModel.fromJson(Map<String, dynamic> json) {
    return CarCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  CarCategoryEntity toEntity() => CarCategoryEntity(id: id, name: name);
}
