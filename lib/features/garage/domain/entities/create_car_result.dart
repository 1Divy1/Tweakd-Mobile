import 'package:equatable/equatable.dart';

/// Presigned upload slot returned by the storage service (step 1 of 3).
/// PUT [uploadUrl] with file bytes; then save [key] to the backend.
class UploadUrlResult extends Equatable {
  final String uploadUrl;
  final String key;

  const UploadUrlResult({
    required this.uploadUrl,
    required this.key,
  });

  @override
  List<Object?> get props => [uploadUrl, key];
}

/// One upload slot from a batch modification upload-urls request.
class ModUploadUrl extends Equatable {
  final String uploadUrl;
  final String key; // R2 key — sent back to the mod's add_media on PATCH
  final String phase; // 'before' or 'after' (lowercase, as returned by backend)

  const ModUploadUrl({
    required this.uploadUrl,
    required this.key,
    required this.phase,
  });

  @override
  List<Object?> get props => [uploadUrl, key, phase];
}

/// Result of requesting multiple modification upload URLs in one shot.
class ModUploadUrlsResult extends Equatable {
  final List<ModUploadUrl> uploads;

  const ModUploadUrlsResult({required this.uploads});

  @override
  List<Object?> get props => [uploads];
}
