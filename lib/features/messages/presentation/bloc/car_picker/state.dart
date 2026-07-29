import 'package:equatable/equatable.dart';

import '../../../../garage/domain/entities/car_summary.dart';

enum GarageCarsStatus { loading, loaded, error }

/// State for the DM car-picker sheet: the viewer's own garage cars.
class GarageCarsState extends Equatable {
  final GarageCarsStatus status;
  final List<CarSummaryEntity> cars;

  const GarageCarsState({
    this.status = GarageCarsStatus.loading,
    this.cars = const [],
  });

  @override
  List<Object?> get props => [status, cars];
}
