import 'package:equatable/equatable.dart';

import 'car.dart';
import 'car_modification.dart';

/// A single presigned upload destination. The client PUTs the (compressed)
/// image bytes directly to [uploadUrl]; [path] is the canonical object path the
/// backend recorded and is what gets sent later to the download-url endpoint.
class UploadSlotEntity extends Equatable {
  final String path;
  final String uploadUrl;

  const UploadSlotEntity({required this.path, required this.uploadUrl});

  @override
  List<Object?> get props => [path, uploadUrl];
}

/// Upload destination for one gallery image, paired with its DB row id.
class GallerySlotEntity extends Equatable {
  final String imageId;
  final String path;
  final String uploadUrl;

  const GallerySlotEntity({
    required this.imageId,
    required this.path,
    required this.uploadUrl,
  });

  @override
  List<Object?> get props => [imageId, path, uploadUrl];
}

/// Before/after upload destinations for one created modification.
class ModificationUploadSlotsEntity extends Equatable {
  final String modificationId;
  final UploadSlotEntity before;
  final UploadSlotEntity after;

  const ModificationUploadSlotsEntity({
    required this.modificationId,
    required this.before,
    required this.after,
  });

  @override
  List<Object?> get props => [modificationId, before, after];
}

/// Result of the single-shot "add car" submission: the created car plus every
/// presigned upload slot. Modification slots are in the same order as the
/// submitted modifications; gallery slots in the requested order.
class CreateCarResult extends Equatable {
  final CarEntity car;
  final UploadSlotEntity cover;
  final List<ModificationUploadSlotsEntity> modifications;
  final List<GallerySlotEntity> gallery;

  const CreateCarResult({
    required this.car,
    required this.cover,
    required this.modifications,
    required this.gallery,
  });

  @override
  List<Object?> get props => [car, cover, modifications, gallery];
}

/// Result of adding a modification to an existing car: the created modification
/// plus its before/after upload slots (mirrors the single-shot create flow).
class AddModificationResult extends Equatable {
  final CarModificationEntity modification;
  final UploadSlotEntity before;
  final UploadSlotEntity after;

  const AddModificationResult({
    required this.modification,
    required this.before,
    required this.after,
  });

  @override
  List<Object?> get props => [modification, before, after];
}
