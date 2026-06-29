import '../../domain/entities/create_car_result.dart';

/// Response from GET /api/storage/cars/{carId}/cover (or /gallery).
/// The backend returns the R2 [key] (sent back on save) and the presigned
/// [uploadUrl] for the direct R2 PUT — no public url is returned anymore.
class UploadUrlResponseModel {
  final String uploadUrl;
  final String key;

  const UploadUrlResponseModel({
    required this.uploadUrl,
    required this.key,
  });

  factory UploadUrlResponseModel.fromJson(Map<String, dynamic> json) {
    return UploadUrlResponseModel(
      uploadUrl: json['upload_url'] as String,
      key: json['key'] as String,
    );
  }

  UploadUrlResult toEntity() => UploadUrlResult(
        uploadUrl: uploadUrl,
        key: key,
      );
}

/// One slot from a batch modification upload-urls response.
class ModUploadUrlModel {
  final String uploadUrl;
  final String key;
  final String phase;

  const ModUploadUrlModel({
    required this.uploadUrl,
    required this.key,
    required this.phase,
  });

  factory ModUploadUrlModel.fromJson(Map<String, dynamic> json) {
    return ModUploadUrlModel(
      uploadUrl: json['upload_url'] as String,
      key: json['key'] as String,
      phase: json['phase'] as String,
    );
  }

  ModUploadUrl toEntity() => ModUploadUrl(
        uploadUrl: uploadUrl,
        key: key,
        phase: phase,
      );
}

/// Response from POST /api/storage/cars/{carId}/modifications/{modId}/upload-urls.
class ModUploadUrlsResponseModel {
  final List<ModUploadUrlModel> uploads;

  const ModUploadUrlsResponseModel({required this.uploads});

  factory ModUploadUrlsResponseModel.fromJson(Map<String, dynamic> json) {
    return ModUploadUrlsResponseModel(
      uploads: (json['uploads'] as List<dynamic>)
          .map((e) => ModUploadUrlModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  ModUploadUrlsResult toEntity() => ModUploadUrlsResult(
        uploads: uploads.map((u) => u.toEntity()).toList(),
      );
}
