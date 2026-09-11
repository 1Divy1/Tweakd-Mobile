import 'package:equatable/equatable.dart';

sealed class CarEventHistoryEvent extends Equatable {
  const CarEventHistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCarEventHistory extends CarEventHistoryEvent {
  final String carId;

  const LoadCarEventHistory(this.carId);

  @override
  List<Object?> get props => [carId];
}
