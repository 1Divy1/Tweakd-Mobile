import 'package:equatable/equatable.dart';

import '../../../../core/shared/entities/image_ref.dart';
import 'car_status_option.dart';

class CarSummaryEntity extends Equatable {
  final String id;
  final String brand;
  final String model;
  final ImageRef? coverImage;
  final CarStatusOptionEntity? status;

  /// The car's owner, surfaced by the backend `CarOwnerDto`. Null on older
  /// payloads that predate the owner field.
  final String? ownerId;
  final String? ownerUsername;

  const CarSummaryEntity({
    required this.id,
    required this.brand,
    required this.model,
    this.coverImage,
    this.status,
    this.ownerId,
    this.ownerUsername,
  });

  @override
  List<Object?> get props =>
      [id, brand, model, coverImage, status, ownerId, ownerUsername];
}
