import '../../domain/entities/car_modification.dart';

class CarModificationModel {
  final String id;
  final String carId;
  final String categoryId;
  final String categoryName;
  final String title;
  final String? description;
  final String? beforeImagePath;
  final String? afterImagePath;
  final DateTime? installationDate;
  final double? price;
  final bool isPricePublic;
  final int? mileageAtInstall;
  final DateTime createdAt;

  const CarModificationModel({
    required this.id,
    required this.carId,
    required this.categoryId,
    required this.categoryName,
    required this.title,
    this.description,
    this.beforeImagePath,
    this.afterImagePath,
    this.installationDate,
    this.price,
    required this.isPricePublic,
    this.mileageAtInstall,
    required this.createdAt,
  });

  factory CarModificationModel.fromJson(Map<String, dynamic> json) {
    return CarModificationModel(
      id: json['id'] as String,
      carId: json['car_id'] as String,
      categoryId: json['category_id'] as String,
      categoryName: json['category_name'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      beforeImagePath: json['before_image_url'] as String?,
      afterImagePath: json['after_image_url'] as String?,
      installationDate: json['installation_date'] != null
          ? DateTime.parse(json['installation_date'] as String)
          : null,
      price: (json['price'] as num?)?.toDouble(),
      isPricePublic: json['is_price_public'] as bool,
      mileageAtInstall: json['mileage_at_install'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  CarModificationEntity toEntity() {
    return CarModificationEntity(
      id: id,
      carId: carId,
      categoryId: categoryId,
      categoryName: categoryName,
      title: title,
      description: description,
      beforeImagePath: beforeImagePath,
      afterImagePath: afterImagePath,
      installationDate: installationDate,
      price: price,
      isPricePublic: isPricePublic,
      mileageAtInstall: mileageAtInstall,
      createdAt: createdAt,
    );
  }
}
