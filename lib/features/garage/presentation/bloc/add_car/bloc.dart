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
  final GetFuelTypeOptionsUseCase getFuelTypeOptions;
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
    required this.getFuelTypeOptions,
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
    final fuelTypeOptionsResult = await getFuelTypeOptions(NoParams());

    if (brandsResult.isLeft() ||
        drivetrainsResult.isLeft() ||
        colorsResult.isLeft() ||
        distanceUnitsResult.isLeft() ||
        statusOptionsResult.isLeft() ||
        modCategoriesResult.isLeft() ||
        fuelTypeOptionsResult.isLeft()) {
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
        fuelTypeOptions: fuelTypeOptionsResult.getOrElse(() => []),
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
    // Images were already compressed at selection time, so each task only has
    // to fetch a presigned URL and PUT the bytes. Cover, gallery and every
    // modification are independent, so they all run concurrently.
    emit(AddCarSubmitting(refData: refData, statusLabel: 'Uploading photos…'));

    try {
      await Future.wait([
        _uploadCover(car.id, event.cover),
        _uploadGallery(car.id, event.gallery),
        for (var i = 0; i < event.mods.length; i++)
          _uploadModMedia(car.id, car.modifications[i].id, event.mods[i]),
      ]);

      emit(AddCarSuccess(car));
    } catch (_) {
      await deleteCar(DeleteCarParams(carId: car.id));
      emit(AddCarError(
        message: 'Photo upload failed. Please try again.',
        refData: refData,
      ));
    }
  }

  /// Fetches a presigned cover slot, uploads the (already compressed) bytes and
  /// registers the final URL on the car.
  Future<void> _uploadCover(String carId, CompressedImage cover) async {
    final slot = (await getCoverUploadUrl(GetCoverUploadUrlParams(carId: carId)))
        .fold((f) => throw Exception(GarageErrorMapper.getMessage(f)), (s) => s);
    await imageService.uploadToR2(slot.uploadUrl, await cover.bytes);
    (await saveCoverUrl(
            SaveCoverUrlParams(carId: carId, finalUrl: slot.finalUrl)))
        .fold((f) => throw Exception(GarageErrorMapper.getMessage(f)), (_) {});
  }

  /// Uploads every gallery image in parallel, then registers the final URLs.
  /// [Future.wait] preserves order, so the saved list matches the user's order.
  Future<void> _uploadGallery(
    String carId,
    List<CompressedImage> gallery,
  ) async {
    if (gallery.isEmpty) return;
    final finalUrls = await Future.wait(gallery.map((image) async {
      final slot =
          (await getGalleryUploadUrl(GetGalleryUploadUrlParams(carId: carId)))
              .fold(
        (f) => throw Exception(GarageErrorMapper.getMessage(f)),
        (s) => s,
      );
      await imageService.uploadToR2(slot.uploadUrl, await image.bytes);
      return slot.finalUrl;
    }));
    (await saveGalleryUrls(
            SaveGalleryUrlsParams(carId: carId, urls: finalUrls)))
        .fold((f) => throw Exception(GarageErrorMapper.getMessage(f)), (_) {});
  }

  /// Requests batch presigned URLs for a modification's before/after images,
  /// uploads them in parallel, then PATCHes the final URLs onto the mod.
  Future<void> _uploadModMedia(
    String carId,
    String modId,
    NewModInput mod,
  ) async {
    final files = <ModUploadRequest>[
      if (mod.before != null)
        const ModUploadRequest(phase: 'BEFORE', format: 'WEBP'),
      if (mod.after != null)
        const ModUploadRequest(phase: 'AFTER', format: 'WEBP'),
    ];
    if (files.isEmpty) return;

    final uploads = (await getModificationUploadUrls(
      GetModificationUploadUrlsParams(carId: carId, modId: modId, files: files),
    ))
        .fold((f) => throw Exception(GarageErrorMapper.getMessage(f)),
            (r) => r.uploads);

    await Future.wait(uploads.map((upload) async {
      final image = upload.phase == 'before' ? mod.before : mod.after;
      if (image == null) return;
      await imageService.uploadToR2(upload.uploadUrl, await image.bytes);
    }));

    final addMedia = uploads
        .map((u) => ModMediaInput(url: u.finalUrl, phase: u.phase))
        .toList();
    (await patchModification(PatchModificationParams(
      carId: carId,
      modId: modId,
      params: ModPatchParams(addMedia: addMedia),
    )))
        .fold((f) => throw Exception(GarageErrorMapper.getMessage(f)), (_) {});
  }
}
