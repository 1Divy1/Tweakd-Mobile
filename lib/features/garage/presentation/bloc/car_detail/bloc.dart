import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/delete_car.dart';
import '../../../domain/usecases/delete_car_image.dart';
import '../../../domain/usecases/delete_modification.dart';
import '../../../domain/usecases/get_car.dart';
import '../../../domain/usecases/get_car_images.dart';
import '../../utils/garage_error_mapper.dart';
import 'event.dart';
import 'state.dart';

@injectable
class CarDetailBloc extends Bloc<CarDetailEvent, CarDetailState> {
  final GetCarUseCase getCarUseCase;
  final GetCarImagesUseCase getCarImagesUseCase;
  final DeleteCarUseCase deleteCarUseCase;
  final DeleteCarImageUseCase deleteCarImageUseCase;
  final DeleteModificationUseCase deleteModificationUseCase;

  CarDetailBloc({
    required this.getCarUseCase,
    required this.getCarImagesUseCase,
    required this.deleteCarUseCase,
    required this.deleteCarImageUseCase,
    required this.deleteModificationUseCase,
  }) : super(const CarDetailLoading()) {
    on<LoadCar>(_onLoadCar);
    on<DeleteCarFromDetail>(_onDeleteCar);
    on<DeleteGalleryImage>(_onDeleteGalleryImage);
    on<DeleteModificationFromDetail>(_onDeleteModification);
  }

  FutureOr<void> _onLoadCar(LoadCar event, Emitter<CarDetailState> emit) async {
    emit(const CarDetailLoading());
    final carResult = await getCarUseCase(GetCarParams(carId: event.carId));

    await carResult.fold(
      (failure) async => emit(
          CarDetailError(message: GarageErrorMapper.getMessage(failure))),
      (car) async {
        final galleryResult =
            await getCarImagesUseCase(GetCarImagesParams(carId: event.carId));
        final gallery = galleryResult.getOrElse(() => []);
        emit(CarDetailLoaded(car: car, gallery: gallery));
      },
    );
  }

  FutureOr<void> _onDeleteCar(
    DeleteCarFromDetail event,
    Emitter<CarDetailState> emit,
  ) async {
    final current = state;
    if (current is! CarDetailLoaded || current.isDeleting) return;

    emit(current.copyWith(isDeleting: true));
    final result = await deleteCarUseCase(DeleteCarParams(carId: event.carId));
    result.fold(
      (failure) {
        emit(CarDetailError(message: GarageErrorMapper.getMessage(failure)));
        emit(current.copyWith(isDeleting: false));
      },
      (_) => emit(const CarDetailDeleted()),
    );
  }

  FutureOr<void> _onDeleteGalleryImage(
    DeleteGalleryImage event,
    Emitter<CarDetailState> emit,
  ) async {
    final current = state;
    if (current is! CarDetailLoaded) return;

    final result = await deleteCarImageUseCase(
      DeleteCarImageParams(carId: event.carId, imageId: event.imageId),
    );
    result.fold(
      (failure) =>
          emit(CarDetailError(message: GarageErrorMapper.getMessage(failure))),
      (_) {
        final updated =
            current.gallery.where((g) => g.id != event.imageId).toList();
        emit(current.copyWith(gallery: updated));
      },
    );
  }

  FutureOr<void> _onDeleteModification(
    DeleteModificationFromDetail event,
    Emitter<CarDetailState> emit,
  ) async {
    final current = state;
    if (current is! CarDetailLoaded) return;

    final result = await deleteModificationUseCase(
      DeleteModificationParams(carId: event.carId, modId: event.modId),
    );
    result.fold(
      (failure) =>
          emit(CarDetailError(message: GarageErrorMapper.getMessage(failure))),
      (_) {
        final updatedMods = current.car.modifications
            .where((m) => m.id != event.modId)
            .toList();
        final updatedCar = current.car.copyWith(modifications: updatedMods);
        emit(current.copyWith(car: updatedCar));
      },
    );
  }
}
