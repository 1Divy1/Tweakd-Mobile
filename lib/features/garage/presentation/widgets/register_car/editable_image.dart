import 'package:equatable/equatable.dart';

import '../../../../../core/services/image_service.dart';

/// An image slot used by the register/edit wizard. In create mode every slot is
/// a freshly picked local file ([LocalSlotImage]); in edit mode an existing
/// photo is a [RemoteSlotImage] (already stored in R2 — never re-uploaded).
sealed class SlotImage extends Equatable {
  const SlotImage();
}

/// An image already stored remotely. Kept as-is unless the user removes it.
/// [url] is for display; [key] is the R2 key sent back to the key-based
/// gallery endpoints when persisting the final list.
class RemoteSlotImage extends SlotImage {
  final String url;
  final String key;
  const RemoteSlotImage(this.url, this.key);

  @override
  List<Object?> get props => [url, key];
}

/// A newly picked local image whose WebP compression is already in flight.
/// Uploaded to R2 on submit.
class LocalSlotImage extends SlotImage {
  final CompressedImage image;
  const LocalSlotImage(this.image);

  @override
  List<Object?> get props => [image];
}
