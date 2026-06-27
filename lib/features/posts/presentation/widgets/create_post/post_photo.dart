import 'package:equatable/equatable.dart';

/// A photo slot used by the create-post wizard. Today every slot is a freshly
/// picked local file ([LocalPostPhoto]); the [RemotePostPhoto] variant is kept
/// for forward-compatibility with editing an existing post (already stored in
/// R2 — never re-uploaded), mirroring the garage wizard's `SlotImage`.
sealed class PostPhoto extends Equatable {
  const PostPhoto();
}

/// A newly picked local image, referenced by its on-device file path. Uploaded
/// to R2 on publish (wired once the backend contract lands).
class LocalPostPhoto extends PostPhoto {
  final String path;
  const LocalPostPhoto(this.path);

  @override
  List<Object?> get props => [path];
}

/// An image already stored remotely. [url] is for display; [key] is the R2 key.
class RemotePostPhoto extends PostPhoto {
  final String url;
  final String key;
  const RemotePostPhoto(this.url, this.key);

  @override
  List<Object?> get props => [url, key];
}
