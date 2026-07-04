import '../../domain/entities/car_status_option.dart';
import '../../domain/entities/reference_data.dart';

class CarBrandModel {
  final String id;
  final String name;

  /// Forum thread count — present only where the backend sends it (forum
  /// contexts); the plain garage catalog omits it.
  final int? threadCount;

  const CarBrandModel({required this.id, required this.name, this.threadCount});

  factory CarBrandModel.fromJson(Map<String, dynamic> json) {
    return CarBrandModel(
      id: json['id'] as String,
      name: json['name'] as String,
      threadCount: (json['thread_count'] as num?)?.toInt(),
    );
  }

  CarBrandEntity toEntity() =>
      CarBrandEntity(id: id, name: name, threadCount: threadCount);
}

class CarModelModel {
  final String id;
  final String brandId;
  final String model;
  final int? threadCount;

  const CarModelModel({
    required this.id,
    required this.brandId,
    required this.model,
    this.threadCount,
  });

  factory CarModelModel.fromJson(Map<String, dynamic> json) {
    return CarModelModel(
      id: json['id'] as String,
      brandId: json['brand_id'] as String,
      model: json['model'] as String,
      threadCount: (json['thread_count'] as num?)?.toInt(),
    );
  }

  CarModelEntity toEntity() => CarModelEntity(
        id: id,
        brandId: brandId,
        model: model,
        threadCount: threadCount,
      );
}

class CarDrivetrainModel {
  final String id;
  final String name;

  const CarDrivetrainModel({required this.id, required this.name});

  factory CarDrivetrainModel.fromJson(Map<String, dynamic> json) {
    return CarDrivetrainModel(id: json['id'] as String, name: json['name'] as String);
  }

  CarDrivetrainEntity toEntity() => CarDrivetrainEntity(id: id, name: name);
}

class CarColorModel {
  final String id;
  final String name;
  final String colorCode;

  const CarColorModel({required this.id, required this.name, required this.colorCode});

  factory CarColorModel.fromJson(Map<String, dynamic> json) {
    return CarColorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      colorCode: json['color_code'] as String,
    );
  }

  CarColorEntity toEntity() => CarColorEntity(id: id, name: name, colorCode: colorCode);
}

class CarDistanceUnitModel {
  final String id;
  final String name;

  const CarDistanceUnitModel({required this.id, required this.name});

  factory CarDistanceUnitModel.fromJson(Map<String, dynamic> json) {
    return CarDistanceUnitModel(id: json['id'] as String, name: json['name'] as String);
  }

  CarDistanceUnitEntity toEntity() => CarDistanceUnitEntity(id: id, name: name);
}

class CarModCategoryModel {
  final String id;
  final String modName;

  const CarModCategoryModel({required this.id, required this.modName});

  factory CarModCategoryModel.fromJson(Map<String, dynamic> json) {
    return CarModCategoryModel(
      id: json['id'] as String,
      modName: json['mod_name'] as String,
    );
  }

  CarModCategoryEntity toEntity() => CarModCategoryEntity(id: id, modName: modName);
}

class CarFuelTypeOptionModel {
  final String id;
  final String name;

  const CarFuelTypeOptionModel({required this.id, required this.name});

  factory CarFuelTypeOptionModel.fromJson(Map<String, dynamic> json) {
    return CarFuelTypeOptionModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  CarFuelTypeOptionEntity toEntity() =>
      CarFuelTypeOptionEntity(id: id, name: name);
}

class CarStatusOptionRefModel {
  final String id;
  final String type;

  const CarStatusOptionRefModel({required this.id, required this.type});

  factory CarStatusOptionRefModel.fromJson(Map<String, dynamic> json) {
    return CarStatusOptionRefModel(
      id: json['id'] as String,
      type: json['type'] as String,
    );
  }

  CarStatusOptionEntity toEntity() => CarStatusOptionEntity(id: id, type: type);
}
