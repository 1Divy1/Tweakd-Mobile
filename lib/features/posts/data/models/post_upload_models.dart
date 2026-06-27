import '../../domain/entities/post_upload.dart';

/// One slot from POST /api/storage/posts/{postId}/upload-urls.
class PostUploadSlotModel {
  final String key;
  final String uploadUrl;

  const PostUploadSlotModel({required this.key, required this.uploadUrl});

  factory PostUploadSlotModel.fromJson(Map<String, dynamic> json) {
    return PostUploadSlotModel(
      key: json['key'] as String,
      uploadUrl: json['upload_url'] as String,
    );
  }

  PostUploadSlot toEntity() => PostUploadSlot(key: key, uploadUrl: uploadUrl);
}

/// Response from POST /api/storage/posts/{postId}/upload-urls.
class PostUploadUrlsResponseModel {
  final List<PostUploadSlotModel> uploads;

  const PostUploadUrlsResponseModel({required this.uploads});

  factory PostUploadUrlsResponseModel.fromJson(Map<String, dynamic> json) {
    return PostUploadUrlsResponseModel(
      uploads: (json['uploads'] as List<dynamic>? ?? [])
          .map((e) => PostUploadSlotModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  PostUploadUrlsResult toEntity() => PostUploadUrlsResult(
        uploads: uploads.map((u) => u.toEntity()).toList(),
      );
}
