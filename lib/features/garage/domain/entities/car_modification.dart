import 'package:equatable/equatable.dart';

class ModificationMediaEntity extends Equatable {
  final String key; // R2 key — sent back to key-based endpoints
  final String url; // fully-qualified url built by the backend — for display
  final String type;  // 'image' or 'video'
  final String phase; // 'before' or 'after'

  const ModificationMediaEntity({
    required this.key,
    required this.url,
    required this.type,
    required this.phase,
  });

  @override
  List<Object?> get props => [key, url, type, phase];
}

class CarModificationEntity extends Equatable {
  final String id;
  final String carId;
  final String categoryId;
  final String categoryName;
  final String title;
  final String? description;
  final List<ModificationMediaEntity> media;
  final DateTime installationDate;

  /// Null for a viewer who is not the owner while [isPricePublic] is false —
  /// the backend leaves it out rather than the app hiding it.
  final double? price;

  /// Whether the owner publishes [price] to other users. Always meaningful to
  /// the owner; for anyone else it only explains why [price] is there.
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
    this.media = const [],
    required this.installationDate,
    this.price,
    this.isPricePublic = false,
    this.mileageAtInstall,
    required this.createdAt,
  });

  List<ModificationMediaEntity> get beforeMedia =>
      media.where((m) => m.phase == 'before').toList();

  List<ModificationMediaEntity> get afterMedia =>
      media.where((m) => m.phase == 'after').toList();

  @override
  List<Object?> get props => [
        id,
        carId,
        categoryId,
        categoryName,
        title,
        description,
        media,
        installationDate,
        price,
        isPricePublic,
        mileageAtInstall,
        createdAt,
      ];
}
