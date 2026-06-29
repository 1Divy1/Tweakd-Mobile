import '../../domain/entities/car_modification.dart';

class ModificationMediaItemModel {
  final String key;
  final String url;
  final String type;
  final String phase;

  const ModificationMediaItemModel({
    required this.key,
    required this.url,
    required this.type,
    required this.phase,
  });

  factory ModificationMediaItemModel.fromJson(Map<String, dynamic> json) {
    return ModificationMediaItemModel(
      key: json['key'] as String,
      url: json['url'] as String,
      type: json['type'] as String,
      phase: json['phase'] as String,
    );
  }

  ModificationMediaEntity toEntity() => ModificationMediaEntity(
        key: key,
        url: url,
        type: type,
        phase: phase,
      );
}

class CarModificationModel {
  final String id;
  final String carId;
  final String categoryId;
  final String categoryName;
  final String title;
  final String? description;
  final List<ModificationMediaItemModel> media;
  final DateTime installationDate;
  final double? price;
  final int? mileageAtInstall;
  final DateTime createdAt;

  const CarModificationModel({
    required this.id,
    required this.carId,
    required this.categoryId,
    required this.categoryName,
    required this.title,
    this.description,
    this.media = const [],
    required this.installationDate,
    this.price,
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
      media: (json['media'] as List<dynamic>? ?? [])
          .map((e) =>
              ModificationMediaItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      installationDate: DateTime.parse(json['installation_date'] as String),
      price: (json['price'] as num?)?.toDouble(),
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
      media: media.map((m) => m.toEntity()).toList(),
      installationDate: installationDate,
      price: price,
      mileageAtInstall: mileageAtInstall,
      createdAt: createdAt,
    );
  }
}
