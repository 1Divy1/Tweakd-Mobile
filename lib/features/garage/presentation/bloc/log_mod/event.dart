import 'package:equatable/equatable.dart';

import '../add_car/event.dart';

abstract class LogModEvent extends Equatable {
  const LogModEvent();

  @override
  List<Object?> get props => [];
}

class LoadModCategories extends LogModEvent {
  const LoadModCategories();
}

class SubmitModification extends LogModEvent {
  final String carId;

  /// The entry's text plus its before/after photos — up to
  /// `maxModImagesPerPhase` per phase, each already being compressed since
  /// selection time.
  final NewModInput input;

  const SubmitModification({required this.carId, required this.input});

  @override
  List<Object?> get props => [carId, input];
}
