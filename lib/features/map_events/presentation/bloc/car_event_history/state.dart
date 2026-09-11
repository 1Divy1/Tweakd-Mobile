import 'package:equatable/equatable.dart';

import '../../../domain/entities/car_event_history.dart';

enum CarEventHistoryStatus { initial, loading, loaded, failure }

/// A car's attended events with its podium places. Failure is deliberately
/// quiet — the section just doesn't render; a car page must never look
/// broken because the events API blipped.
class CarEventHistoryState extends Equatable {
  final CarEventHistoryStatus status;
  final String? carId;
  final List<CarEventHistoryItemEntity> items;

  const CarEventHistoryState({
    this.status = CarEventHistoryStatus.initial,
    this.carId,
    this.items = const [],
  });

  bool get isEmpty => items.isEmpty;

  /// Every podium place across every event, newest first.
  List<CarEventPlacementEntity> get placements =>
      [for (final item in items) ...item.placements];

  @override
  List<Object?> get props => [status, carId, items];
}
