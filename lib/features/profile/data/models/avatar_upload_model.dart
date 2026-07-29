import '../../domain/entities/avatar_upload.dart';

/// Response from `GET /api/storage/avatar`.
class AvatarUploadSlotModel {
  final String key;
  final String uploadUrl;

  const AvatarUploadSlotModel({required this.key, required this.uploadUrl});

  factory AvatarUploadSlotModel.fromJson(Map<String, dynamic> json) {
    return AvatarUploadSlotModel(
      key: json['key'] as String,
      uploadUrl: json['upload_url'] as String,
    );
  }

  AvatarUploadSlot toEntity() =>
      AvatarUploadSlot(key: key, uploadUrl: uploadUrl);
}
