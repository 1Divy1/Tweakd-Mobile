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

/// One modification collected in the wizard. Before and after file paths are
/// optional — the user may provide either, both, or neither.
class NewModInput extends Equatable {
  final ModRequestParams request;
  final String? beforeFilePath;
  final String? afterFilePath;

  const NewModInput({
    required this.request,
    this.beforeFilePath,
    this.afterFilePath,
  });

  @override
  List<Object?> get props => [request, beforeFilePath, afterFilePath];
}

/// Full submission: car specs, local cover file, ordered gallery file paths,
/// and modifications with their optional local before/after images.
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
