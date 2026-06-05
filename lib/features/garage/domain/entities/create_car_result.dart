import 'package:equatable/equatable.dart';

/// Presigned upload slot returned by the storage service (step 1 of 3).
/// PUT [uploadUrl] with file bytes; then save [finalUrl] to the backend.
class UploadUrlResult extends Equatable {
  final String uploadUrl;
  final String finalUrl;
  final String key;

  const UploadUrlResult({
    required this.uploadUrl,
    required this.finalUrl,
    required this.key,
  });

  @override
  List<Object?> get props => [uploadUrl, finalUrl, key];
}

/// One upload slot from a batch modification upload-urls request.
class ModUploadUrl extends Equatable {
  final String uploadUrl;
  final String finalUrl;
  final String phase; // 'before' or 'after' (lowercase, as returned by backend)

  const ModUploadUrl({
    required this.uploadUrl,
    required this.finalUrl,
    required this.phase,
  });

  @override
  List<Object?> get props => [uploadUrl, finalUrl, phase];
}

/// Result of requesting multiple modification upload URLs in one shot.
class ModUploadUrlsResult extends Equatable {
  final List<ModUploadUrl> uploads;

  const ModUploadUrlsResult({required this.uploads});

  @override
  List<Object?> get props => [uploads];
}
