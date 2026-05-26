import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/services/car_image_service.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/repositories/garage_repository.dart';
import '../../../domain/usecases/add_car.dart';
import '../../../domain/usecases/delete_car.dart';
import '../../../domain/usecases/get_cover_upload_url.dart';
import '../../../domain/usecases/get_gallery_upload_url.dart';
import '../../../domain/usecases/get_modification_upload_urls.dart';
import '../../../domain/usecases/get_reference_data.dart';
import '../../../domain/usecases/patch_modification.dart';
import '../../../domain/usecases/save_cover_url.dart';
import '../../../domain/usecases/save_gallery_urls.dart';
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
  final GetCoverUploadUrlUseCase getCoverUploadUrl;
  final SaveCoverUrlUseCase saveCoverUrl;
  final GetGalleryUploadUrlUseCase getGalleryUploadUrl;
  final SaveGalleryUrlsUseCase saveGalleryUrls;
  final GetModificationUploadUrlsUseCase getModificationUploadUrls;
  final PatchModificationUseCase patchModification;
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
    required this.getCoverUploadUrl,
    required this.saveCoverUrl,
    required this.getGalleryUploadUrl,
    required this.saveGalleryUrls,
    required this.getModificationUploadUrls,
    required this.patchModification,
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

    // ── Step 1: create car + mods (text data only) ───────────────────────────
    emit(AddCarSubmitting(refData: refData, statusLabel: 'Creating machine…'));

    final createResult = await addCar(
      CreateCarParams(
        car: event.car,
        modifications: event.mods.map((m) => m.request).toList(),
      ),
    );

    final car = await createResult.fold(
      (failure) async {
        emit(AddCarError(
          message: GarageErrorMapper.getMessage(failure),
          refData: refData,
        ));
        return null;
      },
      (car) async => car,
    );
    if (car == null) return;

    // ── Steps 2–4: upload media; roll back car on any failure ─────────────────
    emit(AddCarSubmitting(refData: refData, statusLabel: 'Uploading photos…'));

    try {
      // Cover image
      final coverSlotResult =
          await getCoverUploadUrl(GetCoverUploadUrlParams(carId: car.id));
      final coverSlot = coverSlotResult.fold(
        (f) => throw Exception(GarageErrorMapper.getMessage(f)),
        (s) => s,
      );
      final coverBytes = await imageService.compressToWebp(event.coverFilePath);
      await imageService.uploadToR2(coverSlot.uploadUrl, coverBytes);
      await saveCoverUrl(
          SaveCoverUrlParams(carId: car.id, finalUrl: coverSlot.finalUrl));

      // Gallery
      if (event.galleryFilePaths.isNotEmpty) {
        final galleryFinalUrls = <String>[];
        for (final filePath in event.galleryFilePaths) {
          final slotResult = await getGalleryUploadUrl(
              GetGalleryUploadUrlParams(carId: car.id));
          final slot = slotResult.fold(
            (f) => throw Exception(GarageErrorMapper.getMessage(f)),
            (s) => s,
          );
          final bytes = await imageService.compressToWebp(filePath);
          await imageService.uploadToR2(slot.uploadUrl, bytes);
          galleryFinalUrls.add(slot.finalUrl);
        }
        await saveGalleryUrls(
            SaveGalleryUrlsParams(carId: car.id, urls: galleryFinalUrls));
      }

      // Modification media
      for (var i = 0; i < event.mods.length; i++) {
        final mod = event.mods[i];
        final modId = car.modifications[i].id;

        final files = <ModUploadRequest>[
          if (mod.beforeFilePath != null)
            const ModUploadRequest(phase: 'BEFORE', format: 'WEBP'),
          if (mod.afterFilePath != null)
            const ModUploadRequest(phase: 'AFTER', format: 'WEBP'),
        ];
        if (files.isEmpty) continue;

        final uploadUrlsResult = await getModificationUploadUrls(
          GetModificationUploadUrlsParams(
              carId: car.id, modId: modId, files: files),
        );
        final uploads = uploadUrlsResult.fold(
          (f) => throw Exception(GarageErrorMapper.getMessage(f)),
          (r) => r.uploads,
        );

        await Future.wait(uploads.map((upload) async {
          final filePath = upload.phase == 'before'
              ? mod.beforeFilePath
              : mod.afterFilePath;
          if (filePath == null) return;
          final bytes = await imageService.compressToWebp(filePath);
          await imageService.uploadToR2(upload.uploadUrl, bytes);
        }));

        final addMedia = uploads
            .map((u) => ModMediaInput(url: u.finalUrl, phase: u.phase))
            .toList();
        await patchModification(PatchModificationParams(
          carId: car.id,
          modId: modId,
          params: ModPatchParams(addMedia: addMedia),
        ));
      }

      emit(AddCarSuccess(car));
    } catch (_) {
      await deleteCar(DeleteCarParams(carId: car.id));
      emit(AddCarError(
        message: 'Photo upload failed. Please try again.',
        refData: refData,
      ));
    }
  }
}
