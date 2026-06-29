import 'package:equatable/equatable.dart';

import '../../../../../core/services/image_service.dart';
import '../../../domain/repositories/garage_repository.dart';
import '../../widgets/register_car/editable_image.dart';
import '../../widgets/register_car/mod_slot.dart';

abstract class AddCarEvent extends Equatable {
  const AddCarEvent();

  @override
  List<Object?> get props => [];
}

class LoadAddCarReferenceData extends AddCarEvent {
  const LoadAddCarReferenceData();
}

class AddCarBrandSelected extends AddCarEvent {
  final String brandId;
  const AddCarBrandSelected(this.brandId);

  @override
  List<Object?> get props => [brandId];
}

/// One modification collected in the wizard. Before and after images are
/// optional — the user may provide either, both, or neither. Each image is
/// already being compressed (see [CompressedImage]).
class NewModInput extends Equatable {
  final ModRequestParams request;
  final CompressedImage? before;
  final CompressedImage? after;

  const NewModInput({
    required this.request,
    this.before,
    this.after,
  });

  @override
  List<Object?> get props => [request, before, after];
}

/// Full submission: car specs, the cover image, the ordered gallery, and the
/// modifications with their optional before/after images. Every image is a
/// [CompressedImage] whose compression was started at selection time, so the
/// submit step only has to upload bytes — no compression happens here.
class SubmitNewCar extends AddCarEvent {
  final CarRequestParams car;
  final CompressedImage cover;
  final List<CompressedImage> gallery;
  final List<NewModInput> mods;

  const SubmitNewCar({
    required this.car,
    required this.cover,
    required this.gallery,
    required this.mods,
  });

  @override
  List<Object?> get props => [car, cover, gallery, mods];
}

/// Edit submission for an existing car. Only changed data is written:
/// - [car] is PUT to update scalar fields.
/// - [newCover] (if set) is uploaded and saved; [removedCover] is true when an
///   existing cover should be deleted from R2 (the backend resolves it by id).
/// - [gallery] is the final ordered list (kept remotes + new locals);
///   [removedGalleryKeys] are existing photos (by R2 key) to delete from R2.
/// - [mods] holds the current mods ([NewModSlot] to create, [ExistingModSlot]
///   to patch); [removedModIds] are mods to delete.
class SubmitCarEdit extends AddCarEvent {
  final String carId;
  final CarRequestParams car;
  final CompressedImage? newCover;
  final bool removedCover;
  final List<SlotImage> gallery;
  final List<String> removedGalleryKeys;
  final List<ModSlot> mods;
  final List<String> removedModIds;

  const SubmitCarEdit({
    required this.carId,
    required this.car,
    this.newCover,
    this.removedCover = false,
    required this.gallery,
    required this.removedGalleryKeys,
    required this.mods,
    required this.removedModIds,
  });

  @override
  List<Object?> get props => [
        carId,
        car,
        newCover,
        removedCover,
        gallery,
        removedGalleryKeys,
        mods,
        removedModIds,
      ];
}
