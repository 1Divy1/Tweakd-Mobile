import '../../domain/entities/create_car_result.dart';
import 'car_detail_model.dart';
import 'car_modification_model.dart';

class UploadSlotModel {
  final String path;
  final String uploadUrl;

  const UploadSlotModel({required this.path, required this.uploadUrl});

  factory UploadSlotModel.fromJson(Map<String, dynamic> json) {
    return UploadSlotModel(
      path: json['path'] as String,
      uploadUrl: json['upload_url'] as String,
    );
  }

  UploadSlotEntity toEntity() =>
      UploadSlotEntity(path: path, uploadUrl: uploadUrl);
}

class GallerySlotModel {
  final String imageId;
  final String path;
  final String uploadUrl;

  const GallerySlotModel({
    required this.imageId,
    required this.path,
    required this.uploadUrl,
  });

  factory GallerySlotModel.fromJson(Map<String, dynamic> json) {
    return GallerySlotModel(
      imageId: json['image_id'] as String,
      path: json['path'] as String,
      uploadUrl: json['upload_url'] as String,
    );
  }

  GallerySlotEntity toEntity() =>
      GallerySlotEntity(imageId: imageId, path: path, uploadUrl: uploadUrl);
}

class ModificationUploadSlotsModel {
  final String modificationId;
  final UploadSlotModel before;
  final UploadSlotModel after;

  const ModificationUploadSlotsModel({
    required this.modificationId,
    required this.before,
    required this.after,
  });

  factory ModificationUploadSlotsModel.fromJson(Map<String, dynamic> json) {
    return ModificationUploadSlotsModel(
      modificationId: json['modification_id'] as String,
      before: UploadSlotModel.fromJson(json['before'] as Map<String, dynamic>),
      after: UploadSlotModel.fromJson(json['after'] as Map<String, dynamic>),
    );
  }

  ModificationUploadSlotsEntity toEntity() => ModificationUploadSlotsEntity(
        modificationId: modificationId,
        before: before.toEntity(),
        after: after.toEntity(),
      );
}

class CreateCarResponseModel {
  final CarDetailModel car;
  final UploadSlotModel cover;
  final List<ModificationUploadSlotsModel> modifications;
  final List<GallerySlotModel> gallery;

  const CreateCarResponseModel({
    required this.car,
    required this.cover,
    required this.modifications,
    required this.gallery,
  });

  factory CreateCarResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateCarResponseModel(
      car: CarDetailModel.fromJson(json['car'] as Map<String, dynamic>),
      cover: UploadSlotModel.fromJson(json['cover'] as Map<String, dynamic>),
      modifications: (json['modifications'] as List<dynamic>)
          .map((e) =>
              ModificationUploadSlotsModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      gallery: (json['gallery'] as List<dynamic>)
          .map((e) => GallerySlotModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  CreateCarResult toEntity() => CreateCarResult(
        car: car.toEntity(),
        cover: cover.toEntity(),
        modifications: modifications.map((m) => m.toEntity()).toList(),
        gallery: gallery.map((g) => g.toEntity()).toList(),
      );
}

/// Response for adding a modification to an existing car. The backend does not
/// issue before/after upload slots for this endpoint yet; this model assumes
/// the symmetric shape it will return once that lands (mirrors the per-mod
/// slots embedded in the single-shot create response).
class AddModificationResponseModel {
  final CarModificationModel modification;
  final UploadSlotModel before;
  final UploadSlotModel after;

  const AddModificationResponseModel({
    required this.modification,
    required this.before,
    required this.after,
  });

  factory AddModificationResponseModel.fromJson(Map<String, dynamic> json) {
    return AddModificationResponseModel(
      modification: CarModificationModel.fromJson(
          json['modification'] as Map<String, dynamic>),
      before: UploadSlotModel.fromJson(json['before'] as Map<String, dynamic>),
      after: UploadSlotModel.fromJson(json['after'] as Map<String, dynamic>),
    );
  }

  AddModificationResult toEntity() => AddModificationResult(
        modification: modification.toEntity(),
        before: before.toEntity(),
        after: after.toEntity(),
      );
}
