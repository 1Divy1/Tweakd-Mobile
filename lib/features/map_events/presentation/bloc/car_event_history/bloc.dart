import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/map_event_contests.dart';
import 'event.dart';
import 'state.dart';

/// Backs the "Events" section of the car page.
@injectable
class CarEventHistoryBloc
    extends Bloc<CarEventHistoryEvent, CarEventHistoryState> {
  final GetCarEventHistoryUseCase getHistory;

  CarEventHistoryBloc({required this.getHistory})
      : super(const CarEventHistoryState()) {
    on<LoadCarEventHistory>(_onLoad);
  }

  Future<void> _onLoad(
    LoadCarEventHistory event,
    Emitter<CarEventHistoryState> emit,
  ) async {
    emit(CarEventHistoryState(
      status: CarEventHistoryStatus.loading,
      carId: event.carId,
    ));
    final result = await getHistory(GetCarEventHistoryParams(carId: event.carId));
    if (state.carId != event.carId) return;
    result.fold(
      (_) => emit(CarEventHistoryState(
        status: CarEventHistoryStatus.failure,
        carId: event.carId,
      )),
      (items) => emit(CarEventHistoryState(
        status: CarEventHistoryStatus.loaded,
        carId: event.carId,
        items: items,
      )),
    );
  }
}
