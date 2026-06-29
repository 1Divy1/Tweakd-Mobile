import 'package:equatable/equatable.dart';

/// One presigned upload slot for a post image: the R2 [key] to commit back to
/// the post, and the [uploadUrl] to PUT the WebP bytes to directly.
class PostUploadSlot extends Equatable {
  final String key;
  final String uploadUrl;

  const PostUploadSlot({required this.key, required this.uploadUrl});

  @override
  List<Object?> get props => [key, uploadUrl];
}

/// The batch of presigned slots returned for a post. The slot order is
/// arbitrary — the caller decides display order when committing the keys.
class PostUploadUrlsResult extends Equatable {
  final List<PostUploadSlot> uploads;

  const PostUploadUrlsResult({required this.uploads});

  @override
  List<Object?> get props => [uploads];
}
