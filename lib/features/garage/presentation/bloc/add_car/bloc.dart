import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/services/car_image_service.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/repositories/garage_repository.dart';
import '../../../domain/usecases/add_car.dart';
import '../../../domain/usecases/delete_car.dart';
import '../../../domain/usecases/get_reference_data.dart';
import '../../utils/garage_error_mapper.dart';
import 'event.dart';
import 'state.dart';

@injectable
class AddCarBloc extends Bloc<AddCarEvent, AddCarState> {
  final GetBrandsUseCase getBrands;
  final GetModelsByBrandUseCase getModelsByBrand;
  final GetDrivetrainsUseCase getDrivetrains;
  final GetColorsUseCase getColors;
  final GetDistanceUnitsUseCase getDistanceUnits;
  final GetStatusOptionsUseCase getStatusOptions;
  final GetModCategoriesUseCase getModCategories;
  final AddCarUseCase addCar;
  final DeleteCarUseCase deleteCar;
  final CarImageService imageService;

  AddCarBloc({
    required this.getBrands,
    required this.getModelsByBrand,
    required this.getDrivetrains,
    required this.getColors,
    required this.getDistanceUnits,
    required this.getStatusOptions,
    required this.getModCategories,
    required this.addCar,
    required this.deleteCar,
    required this.imageService,
  }) : super(const AddCarInitial()) {
    on<LoadAddCarReferenceData>(_onLoadRefData);
    on<AddCarBrandSelected>(_onBrandSelected);
    on<SubmitNewCar>(_onSubmit);
  }

  FutureOr<void> _onLoadRefData(
    LoadAddCarReferenceData event,
    Emitter<AddCarState> emit,
  ) async {
    emit(const AddCarRefDataLoading());

    final brandsResult = await getBrands(NoParams());
    final drivetrainsResult = await getDrivetrains(NoParams());
    final colorsResult = await getColors(NoParams());
    final distanceUnitsResult = await getDistanceUnits(NoParams());
    final statusOptionsResult = await getStatusOptions(NoParams());
    final modCategoriesResult = await getModCategories(NoParams());

    if (brandsResult.isLeft() ||
        drivetrainsResult.isLeft() ||
        colorsResult.isLeft() ||
        distanceUnitsResult.isLeft() ||
        statusOptionsResult.isLeft() ||
        modCategoriesResult.isLeft()) {
      emit(const AddCarRefDataError(
          message: 'Failed to load form data. Please try again.'));
      return;
    }

    emit(
      AddCarRefDataLoaded(
        brands: brandsResult.getOrElse(() => []),
        drivetrains: drivetrainsResult.getOrElse(() => []),
        colors: colorsResult.getOrElse(() => []),
        distanceUnits: distanceUnitsResult.getOrElse(() => []),
        statusOptions: statusOptionsResult.getOrElse(() => []),
        modCategories: modCategoriesResult.getOrElse(() => []),
      ),
    );
  }

  FutureOr<void> _onBrandSelected(
    AddCarBrandSelected event,
    Emitter<AddCarState> emit,
  ) async {
    final current = state;
    if (current is! AddCarRefDataLoaded) return;

    emit(current.copyWith(models: [], modelsLoading: true));

    final result = await getModelsByBrand(
      GetModelsByBrandParams(brandId: event.brandId),
    );

    result.fold(
      (_) => emit(current.copyWith(models: [], modelsLoading: false)),
      (models) => emit(current.copyWith(models: models, modelsLoading: false)),
    );
  }

  FutureOr<void> _onSubmit(
    SubmitNewCar event,
    Emitter<AddCarState> emit,
  ) async {
    final current = state;
    final refData = switch (current) {
      AddCarRefDataLoaded() => current,
      AddCarSubmitting(:final refData) => refData,
      AddCarError(:final refData) => refData,
      _ => null,
    };
    if (refData == null) return;

    emit(AddCarSubmitting(refData: refData, statusLabel: 'Creating machine…'));

    final createResult = await addCar(
      CreateCarParams(
        car: event.car,
        modifications: event.mods.map((m) => m.request).toList(),
        galleryCount: event.galleryFilePaths.length,
      ),
    );

    final result = await createResult.fold(
      (failure) async {
        emit(AddCarError(
          message: GarageErrorMapper.getMessage(failure),
          refData: refData,
        ));
        return null;
      },
      (created) async => created,
    );
    if (result == null) return;

    emit(AddCarSubmitting(refData: refData, statusLabel: 'Uploading photos…'));

    try {
      final uploads = <Future<void>>[
        imageService.uploadToSignedUrl(
            result.cover.uploadUrl, event.coverFilePath),
      ];

      for (var i = 0; i < event.mods.length; i++) {
        final slots = result.modifications[i];
        uploads.add(imageService.uploadToSignedUrl(
            slots.before.uploadUrl, event.mods[i].beforeFilePath));
        uploads.add(imageService.uploadToSignedUrl(
            slots.after.uploadUrl, event.mods[i].afterFilePath));
      }

      for (var i = 0; i < event.galleryFilePaths.length; i++) {
        uploads.add(imageService.uploadToSignedUrl(
            result.gallery[i].uploadUrl, event.galleryFilePaths[i]));
      }

      await Future.wait(uploads);
      emit(AddCarSuccess(result.car));
    } catch (_) {
      // Roll back the orphaned car so the user can safely retry.
      await deleteCar(DeleteCarParams(carId: result.car.id));
      emit(AddCarError(
        message: 'Photo upload failed. Please try again.',
        refData: refData,
      ));
    }
  }
}
