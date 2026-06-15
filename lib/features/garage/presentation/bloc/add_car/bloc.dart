import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/services/car_image_service.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/repositories/garage_repository.dart';
import '../../../domain/usecases/add_car.dart';
import '../../../domain/usecases/add_modification.dart';
import '../../../domain/usecases/delete_car.dart';
import '../../../domain/usecases/delete_cover_image.dart';
import '../../../domain/usecases/delete_gallery_images.dart';
import '../../../domain/usecases/delete_modification.dart';
import '../../../domain/usecases/get_cover_upload_url.dart';
import '../../../domain/usecases/get_gallery_upload_url.dart';
import '../../../domain/usecases/get_modification_upload_urls.dart';
import '../../../domain/usecases/get_reference_data.dart';
import '../../../domain/usecases/patch_modification.dart';
import '../../../domain/usecases/save_cover_url.dart';
import '../../../domain/usecases/save_gallery_urls.dart';
import '../../../domain/usecases/update_car.dart';
import '../../widgets/register_car/editable_image.dart';
import '../../widgets/register_car/mod_slot.dart';
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
  final UpdateCarUseCase updateCar;
  final DeleteCarUseCase deleteCar;
  final GetCoverUploadUrlUseCase getCoverUploadUrl;
  final SaveCoverUrlUseCase saveCoverUrl;
  final DeleteCoverImageUseCase deleteCoverImage;
  final GetGalleryUploadUrlUseCase getGalleryUploadUrl;
  final SaveGalleryUrlsUseCase saveGalleryUrls;
  final DeleteGalleryImagesUseCase deleteGalleryImages;
  final AddModificationUseCase addModification;
  final GetModificationUploadUrlsUseCase getModificationUploadUrls;
  final PatchModificationUseCase patchModification;
  final DeleteModificationUseCase deleteModification;
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
    required this.updateCar,
    required this.deleteCar,
    required this.getCoverUploadUrl,
    required this.saveCoverUrl,
    required this.deleteCoverImage,
    required this.getGalleryUploadUrl,
    required this.saveGalleryUrls,
    required this.deleteGalleryImages,
    required this.addModification,
    required this.getModificationUploadUrls,
    required this.patchModification,
    required this.deleteModification,
    required this.imageService,
  }) : super(const AddCarInitial()) {
    on<LoadAddCarReferenceData>(_onLoadRefData);
    on<AddCarBrandSelected>(_onBrandSelected);
    on<SubmitNewCar>(_onSubmit);
    on<SubmitCarEdit>(_onSubmitEdit);
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

  // ── Edit ───────────────────────────────────────────────────────────────────

  /// Applies an edit to an existing car. Only changed data is written: scalar
  /// fields via PUT, new images uploaded to R2, removed images deleted from R2,
  /// and modifications created / patched / deleted as needed. Unlike create,
  /// failures do not roll back already-saved changes — they surface an error.
  FutureOr<void> _onSubmitEdit(
    SubmitCarEdit event,
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

    emit(AddCarSubmitting(refData: refData, statusLabel: 'Saving changes…'));

    final updateResult = await updateCar(
      UpdateCarParams(carId: event.carId, request: event.car),
    );
    final updatedCar = updateResult.fold(
      (failure) {
        emit(AddCarError(
          message: GarageErrorMapper.getMessage(failure),
          refData: refData,
        ));
        return null;
      },
      (car) => car,
    );
    if (updatedCar == null) return;

    try {
      emit(AddCarSubmitting(refData: refData, statusLabel: 'Saving photos…'));

      // ── Cover ──────────────────────────────────────────────────────────────
      if (event.newCover != null) {
        await _replaceCover(
            event.carId, event.newCover!, event.removedCoverUrl);
      }

      // ── Gallery ────────────────────────────────────────────────────────────
      final galleryChanged = event.gallery.any((s) => s is LocalSlotImage) ||
          event.removedGalleryUrls.isNotEmpty;
      if (galleryChanged) {
        // Delete removed photos first — while their rows still exist — since the
        // backend scopes R2 deletion to the car's current gallery rows. Saving
        // the new full list first would drop those rows and orphan the objects.
        if (event.removedGalleryUrls.isNotEmpty) {
          (await deleteGalleryImages(DeleteGalleryImagesParams(
            carId: event.carId,
            urls: event.removedGalleryUrls,
          )))
              .fold(
                  (f) => throw Exception(GarageErrorMapper.getMessage(f)), (_) {});
        }
        // Upload any new locals, then persist the final ordered list.
        final finalUrls = <String>[];
        for (final slot in event.gallery) {
          switch (slot) {
            case RemoteSlotImage(:final url):
              finalUrls.add(url);
            case LocalSlotImage(:final image):
              finalUrls.add(await _uploadGalleryImage(event.carId, image));
          }
        }
        (await saveGalleryUrls(
                SaveGalleryUrlsParams(carId: event.carId, urls: finalUrls)))
            .fold((f) => throw Exception(GarageErrorMapper.getMessage(f)), (_) {});
      }

      // ── Modifications ───────────────────────────────────────────────────────
      for (final modId in event.removedModIds) {
        (await deleteModification(
                DeleteModificationParams(carId: event.carId, modId: modId)))
            .fold((f) => throw Exception(GarageErrorMapper.getMessage(f)), (_) {});
      }
      for (final slot in event.mods) {
        switch (slot) {
          case NewModSlot(:final input):
            final created = (await addModification(AddModificationParams(
              carId: event.carId,
              request: input.request,
            )))
                .fold((f) => throw Exception(GarageErrorMapper.getMessage(f)),
                    (m) => m);
            await _uploadModMedia(event.carId, created.id, input);
          case ExistingModSlot():
            await _patchExistingMod(event.carId, slot);
        }
      }

      emit(AddCarSuccess(updatedCar));
    } catch (_) {
      emit(AddCarError(
        message: 'Some changes could not be saved. Please try again.',
        refData: refData,
      ));
    }
  }

  /// Uploads a single (already compressed) gallery image and returns its final
  /// public URL. Throws on failure so the edit flow can surface an error.
  Future<String> _uploadGalleryImage(
      String carId, CompressedImage image) async {
    final slot =
        (await getGalleryUploadUrl(GetGalleryUploadUrlParams(carId: carId)))
            .fold(
      (f) => throw Exception(GarageErrorMapper.getMessage(f)),
      (s) => s,
    );
    await imageService.uploadToR2(slot.uploadUrl, await image.bytes);
    return slot.finalUrl;
  }

  /// Replaces the car's cover. Uploads the new file to R2 first, then deletes
  /// the old cover object (the backend's DELETE /cover targets the *current*
  /// cover, so this must run before the cover pointer is moved), then points
  /// the car at the new cover. Ordering keeps the window where the car has no
  /// cover sub-second and self-healing if a later step fails.
  Future<void> _replaceCover(
    String carId,
    CompressedImage cover,
    String? oldUrl,
  ) async {
    final slot = (await getCoverUploadUrl(GetCoverUploadUrlParams(carId: carId)))
        .fold((f) => throw Exception(GarageErrorMapper.getMessage(f)), (s) => s);
    await imageService.uploadToR2(slot.uploadUrl, await cover.bytes);

    if (oldUrl != null) {
      (await deleteCoverImage(DeleteCoverImageParams(carId: carId, url: oldUrl)))
          .fold(
              (f) => throw Exception(GarageErrorMapper.getMessage(f)), (_) {});
    }

    (await saveCoverUrl(
            SaveCoverUrlParams(carId: carId, finalUrl: slot.finalUrl)))
        .fold((f) => throw Exception(GarageErrorMapper.getMessage(f)), (_) {});
  }

  /// Uploads any newly picked before/after images for an existing mod, then
  /// PATCHes the text diff + added media + removed media in a single call.
  /// No-ops when nothing changed.
  Future<void> _patchExistingMod(String carId, ExistingModSlot slot) async {
    final files = <ModUploadRequest>[
      if (slot.newBefore != null)
        const ModUploadRequest(phase: 'BEFORE', format: 'WEBP'),
      if (slot.newAfter != null)
        const ModUploadRequest(phase: 'AFTER', format: 'WEBP'),
    ];

    final addMedia = <ModMediaInput>[];
    if (files.isNotEmpty) {
      final uploads = (await getModificationUploadUrls(
        GetModificationUploadUrlsParams(
            carId: carId, modId: slot.modId, files: files),
      ))
          .fold((f) => throw Exception(GarageErrorMapper.getMessage(f)),
              (r) => r.uploads);

      await Future.wait(uploads.map((upload) async {
        final image = upload.phase == 'before' ? slot.newBefore : slot.newAfter;
        if (image == null) return;
        await imageService.uploadToR2(upload.uploadUrl, await image.bytes);
      }));

      addMedia.addAll(
          uploads.map((u) => ModMediaInput(url: u.finalUrl, phase: u.phase)));
    }

    final patch =
        slot.toPatchParams(addMedia: addMedia.isEmpty ? null : addMedia);
    if (patch.toJson().isEmpty) return; // nothing changed

    (await patchModification(PatchModificationParams(
      carId: carId,
      modId: slot.modId,
      params: patch,
    )))
        .fold((f) => throw Exception(GarageErrorMapper.getMessage(f)), (_) {});
  }
}
