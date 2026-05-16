import 'package:equatable/equatable.dart';

class CarModificationEntity extends Equatable {
  final String id;
  final String carId;
  final String categoryId;
  final String categoryName;
  final String title;
  final String? description;

  /// Canonical storage paths. Resolve to signed URLs before display.
  final String? beforeImagePath;
  final String? afterImagePath;
  final DateTime? installationDate;
  final double? price;
  final bool isPricePublic;
  final int? mileageAtInstall;
  final DateTime createdAt;

  const CarModificationEntity({
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

  @override
  List<Object?> get props => [
        id,
        carId,
        categoryId,
        categoryName,
        title,
        description,
        beforeImagePath,
        afterImagePath,
        installationDate,
        price,
        isPricePublic,
        mileageAtInstall,
        createdAt,
      ];
}
