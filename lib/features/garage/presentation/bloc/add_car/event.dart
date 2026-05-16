import 'package:equatable/equatable.dart';

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

/// One modification collected in the wizard, with its local before/after image
/// file paths (uploaded after the car is created).
class NewModInput extends Equatable {
  final ModRequestParams request;
  final String beforeFilePath;
  final String afterFilePath;

  const NewModInput({
    required this.request,
    required this.beforeFilePath,
    required this.afterFilePath,
  });

  @override
  List<Object?> get props => [request, beforeFilePath, afterFilePath];
}

/// Full single-shot submission: car specs, the local cover file, ordered
/// gallery file paths, and the modifications with their local images.
class SubmitNewCar extends AddCarEvent {
  final CarRequestParams car;
  final String coverFilePath;
  final List<String> galleryFilePaths;
  final List<NewModInput> mods;

  const SubmitNewCar({
    required this.car,
    required this.coverFilePath,
    required this.galleryFilePaths,
    required this.mods,
  });

  @override
  List<Object?> get props => [car, coverFilePath, galleryFilePaths, mods];
}
