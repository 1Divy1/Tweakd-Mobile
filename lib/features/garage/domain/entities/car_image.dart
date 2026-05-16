import 'package:equatable/equatable.dart';

/// A single gallery image belonging to a car.
class CarImageEntity extends Equatable {
  final String id;

  /// Canonical storage path. Resolve to a signed URL before display.
  final String storagePath;
  final int displayOrder;
  final DateTime createdAt;

  const CarImageEntity({
    required this.id,
    required this.storagePath,
    required this.displayOrder,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, storagePath, displayOrder, createdAt];
}
