import 'package:equatable/equatable.dart';

import '../../../../../core/services/car_image_service.dart';
import '../../../domain/repositories/garage_repository.dart';

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
