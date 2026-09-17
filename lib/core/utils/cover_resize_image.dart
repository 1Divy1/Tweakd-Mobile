import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Decodes [imageProvider] scaled down so its *shortest* side is
/// [shortestSide] pixels, keeping the aspect ratio.
///
/// This is the decode size `BoxFit.cover` needs for a square box: the image
/// fills the box without being upscaled, and nothing larger than necessary is
/// held in memory.
///
/// Why not [ResizeImage]: given both a width and a height, its default
/// `ResizeImagePolicy.exact` decodes to exactly that rectangle — a portrait
/// photo forced into a square comes out squashed, and `cover` can't undo it
/// because the bitmap is already square. `ResizeImagePolicy.fit` keeps the
/// ratio but fits the *longest* side, leaving the short side too small and the
/// avatar blurry.
@immutable
class CoverResizeImage extends ImageProvider<CoverResizeImageKey> {
  final ImageProvider imageProvider;
  final int shortestSide;

  const CoverResizeImage(this.imageProvider, {required this.shortestSide})
    : assert(shortestSide > 0);

  @override
  Future<CoverResizeImageKey> obtainKey(ImageConfiguration configuration) {
    // `then` on a SynchronousFuture stays synchronous, so a cached image still
    // paints on the first frame.
    return imageProvider
        .obtainKey(configuration)
        .then((key) => CoverResizeImageKey(key, shortestSide));
  }

  @override
  ImageStreamCompleter loadImage(
    CoverResizeImageKey key,
    ImageDecoderCallback decode,
  ) {
    Future<ui.Codec> decodeCover(
      ui.ImmutableBuffer buffer, {
      ui.TargetImageSizeCallback? getTargetSize,
    }) {
      return decode(
        buffer,
        getTargetSize: (int intrinsicWidth, int intrinsicHeight) {
          final shortest = math.min(intrinsicWidth, intrinsicHeight);
          if (shortest <= shortestSide) return const ui.TargetImageSize();
          final scale = shortestSide / shortest;
          return ui.TargetImageSize(
            width: math.max(1, (intrinsicWidth * scale).round()),
            height: math.max(1, (intrinsicHeight * scale).round()),
          );
        },
      );
    }

    final completer = imageProvider.loadImage(key.providerKey, decodeCover);
    // Same as ResizeImage: a failed load must not stay cached under our key,
    // or the image never retries.
    completer.addEphemeralErrorListener((_, _) {
      scheduleMicrotask(() => PaintingBinding.instance.imageCache.evict(key));
    });
    return completer;
  }
}

@immutable
class CoverResizeImageKey {
  final Object providerKey;
  final int shortestSide;

  const CoverResizeImageKey(this.providerKey, this.shortestSide);

  @override
  bool operator ==(Object other) =>
      other is CoverResizeImageKey &&
      other.providerKey == providerKey &&
      other.shortestSide == shortestSide;

  @override
  int get hashCode => Object.hash(providerKey, shortestSide);
}
