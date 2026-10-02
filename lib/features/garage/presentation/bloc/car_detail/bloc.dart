import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/delete_car.dart';
import '../../../domain/usecases/delete_gallery_images.dart';
import '../../../domain/usecases/delete_modification.dart';
import '../../../domain/usecases/get_car.dart';
import 'package:tweakd/core/analytics/analytics_events.dart';
import 'package:tweakd/core/analytics/analytics_service.dart';
import 'package:tweakd/features/posts/domain/entities/post_params.dart';
import 'package:tweakd/features/posts/domain/usecases/share_modification.dart';
import '../../utils/garage_error_mapper.dart';
import 'event.dart';
import 'state.dart';

@injectable
class CarDetailBloc extends Bloc<CarDetailEvent, CarDetailState> {
  final GetCarUseCase getCarUseCase;
  final DeleteCarUseCase deleteCarUseCase;
  final DeleteGalleryImagesUseCase deleteGalleryImagesUseCase;
  final DeleteModificationUseCase deleteModificationUseCase;
  final ShareModificationUseCase shareModificationUseCase;
  final AnalyticsService analytics;

  CarDetailBloc({
    required this.getCarUseCase,
    required this.deleteCarUseCase,
    required this.deleteGalleryImagesUseCase,
    required this.deleteModificationUseCase,
    required this.shareModificationUseCase,
    this.analytics = const NoopAnalyticsService(),
  }) : super(const CarDetailLoading()) {
    on<LoadCar>(_onLoadCar);
    on<DeleteCarFromDetail>(_onDeleteCar);
    on<DeleteGalleryImage>(_onDeleteGalleryImage);
    on<ShareModificationFromDetail>(_onShareModification);
    on<DeleteModificationFromDetail>(_onDeleteModification);
  }

  FutureOr<void> _onLoadCar(LoadCar event, Emitter<CarDetailState> emit) async {
    emit(const CarDetailLoading());
    final result = await getCarUseCase(GetCarParams(carId: event.carId));
    result.fold(
      (failure) =>
          emit(CarDetailError(code: GarageErrorMapper.getCode(failure))),
      (car) => emit(CarDetailLoaded(car: car)),
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
      (failure) => emit(current.copyWith(
        isDeleting: false,
        deleteFailedCode: GarageErrorMapper.getCode(failure),
      )),
      (_) => emit(const CarDetailDeleted()),
    );
  }

  FutureOr<void> _onDeleteGalleryImage(
    DeleteGalleryImage event,
    Emitter<CarDetailState> emit,
  ) async {
    final current = state;
    if (current is! CarDetailLoaded) return;

    final updatedGallery = current.car.gallery
        .where((ref) => ref.key != event.imageKey)
        .toList();

    // Deletes the photo from both the DB list and R2 storage.
    final result = await deleteGalleryImagesUseCase(
      DeleteGalleryImagesParams(carId: event.carId, keys: [event.imageKey]),
    );
    result.fold(
      (failure) =>
          emit(CarDetailError(code: GarageErrorMapper.getCode(failure))),
      (_) {
        final updatedCar = current.car.copyWith(gallery: updatedGallery);
        emit(current.copyWith(car: updatedCar));
      },
    );
  }

  FutureOr<void> _onShareModification(
    ShareModificationFromDetail event,
    Emitter<CarDetailState> emit,
  ) async {
    final current = state;
    if (current is! CarDetailLoaded || current.sharingModId != null) return;

    final mod = current.car.modifications
        .where((m) => m.id == event.modId)
        .firstOrNull;
    // Already shared: the row links to the post, so there is nothing to post.
    if (mod == null || mod.isSharedToFeed) return;

    emit(current.copyWith(sharingModId: event.modId));

    final result = await shareModificationUseCase(
      ShareModificationParams(modificationId: event.modId),
    );

    final latest = state;
    if (latest is! CarDetailLoaded) return;

    result.fold(
      (_) => emit(latest.copyWith(shareFailedModId: event.modId)),
      (post) {
        analytics.track(AnalyticsEvents.modificationShared, {
          'source': 'build_log',
          'auto': false,
          'image_count': mod.media.length,
        });
        // The row flips to "shared" from the post the backend just handed back,
        // so it is right without re-fetching the car.
        final updatedMods = [
          for (final m in latest.car.modifications)
            if (m.id == event.modId) m.copyWith(sharedPostId: post.id) else m,
        ];
        emit(latest.copyWith(
          car: latest.car.copyWith(modifications: updatedMods),
        ));
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
          emit(CarDetailError(code: GarageErrorMapper.getCode(failure))),
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
