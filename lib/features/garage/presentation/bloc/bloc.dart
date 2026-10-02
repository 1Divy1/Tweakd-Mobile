import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_garage_by_username.dart';
import '../../domain/usecases/get_my_garage.dart';
import '../utils/garage_error_mapper.dart';
import 'event.dart';
import 'state.dart';

@injectable
class GarageBloc extends Bloc<GarageEvent, GarageState> {
  final GetMyGarageUseCase getMyGarage;
  final GetGarageByUsernameUseCase getGarageByUsername;

  GarageBloc({
    required this.getMyGarage,
    required this.getGarageByUsername,
  }) : super(const GarageInitial()) {
    on<LoadMyGarage>(_onLoadMyGarage);
    on<LoadGarageByUsername>(_onLoadGarageByUsername);
    on<CarRemovedFromGarage>(_onCarRemoved);
  }

  FutureOr<void> _onLoadMyGarage(
    LoadMyGarage event,
    Emitter<GarageState> emit,
  ) async {
    emit(const GarageLoading());
    final result = await getMyGarage(NoParams());
    result.fold(
      (failure) => emit(GarageError(code: GarageErrorMapper.getCode(failure))),
      (garage) => emit(GarageLoaded(garage: garage)),
    );
  }

  FutureOr<void> _onLoadGarageByUsername(
    LoadGarageByUsername event,
    Emitter<GarageState> emit,
  ) async {
    emit(const GarageLoading());
    final result = await getGarageByUsername(
      GetGarageByUsernameParams(username: event.username),
    );
    result.fold(
      (failure) => emit(GarageError(code: GarageErrorMapper.getCode(failure))),
      (garage) => emit(GarageLoaded(garage: garage)),
    );
  }

  /// The car was already deleted on the server (from its detail page), so this
  /// only drops it from the list — no refetch, no loading flash.
  void _onCarRemoved(CarRemovedFromGarage event, Emitter<GarageState> emit) {
    final current = state;
    if (current is! GarageLoaded) return;
    final cars = current.garage.cars.where((c) => c.id != event.carId).toList();
    emit(GarageLoaded(garage: current.garage.copyWith(cars: cars)));
  }
}
