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

  /// Headline specs shown on the garage card, straight off `CarSummaryDto`.
  /// Nullable defensively — the DTO sends primitives, so a missing key means a
  /// payload older than the projection, and the card draws one fewer cell
  /// instead of throwing.
  final int? year;
  final int? horsepower;
  final int? torque;

  const CarSummaryEntity({
    required this.id,
    required this.brand,
    required this.model,
    this.coverImage,
    this.status,
    this.ownerId,
    this.ownerUsername,
    this.year,
    this.horsepower,
    this.torque,
  });

  @override
  List<Object?> get props => [
    id,
    brand,
    model,
    coverImage,
    status,
    ownerId,
    ownerUsername,
    year,
    horsepower,
    torque,
  ];
}
