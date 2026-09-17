// Regression guard for squashed avatars: the avatar widgets used to decode
// with `ResizeImage(width: px, height: px)`, whose default exact policy forces
// any photo into a square bitmap — a portrait selfie came out squashed, and
// `BoxFit.cover` couldn't undo it. CoverResizeImage must keep the aspect ratio
// and only shrink until the shortest side matches the requested size.
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/core/utils/cover_resize_image.dart';

Future<MemoryImage> _png(int width, int height) async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawRect(
    Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    Paint()..color = const Color(0xFFFF0000),
  );
  final image = await recorder.endRecording().toImage(width, height);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return MemoryImage(bytes!.buffer.asUint8List());
}

Future<Size> _decodedSize(ImageProvider provider) async {
  final stream = provider.resolve(ImageConfiguration.empty);
  final info = await _firstImage(stream);
  final size = Size(info.image.width.toDouble(), info.image.height.toDouble());
  info.dispose();
  return size;
}

Future<ImageInfo> _firstImage(ImageStream stream) {
  final completer = Completer<ImageInfo>();
  late final ImageStreamListener listener;
  listener = ImageStreamListener(
    (info, _) {
      stream.removeListener(listener);
      completer.complete(info.clone());
    },
    onError: (error, stack) {
      stream.removeListener(listener);
      completer.completeError(error, stack);
    },
  );
  stream.addListener(listener);
  return completer.future;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('portrait photo keeps its ratio, short side matches', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final size = await _decodedSize(
        CoverResizeImage(await _png(300, 600), shortestSide: 100),
      );
      expect(size, const Size(100, 200));
    });
  });

  testWidgets('landscape photo keeps its ratio, short side matches', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final size = await _decodedSize(
        CoverResizeImage(await _png(800, 400), shortestSide: 120),
      );
      expect(size, const Size(240, 120));
    });
  });

  testWidgets('a photo already smaller than the target is never upscaled', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final size = await _decodedSize(
        CoverResizeImage(await _png(60, 90), shortestSide: 120),
      );
      expect(size, const Size(60, 90));
    });
  });

  test('different target sizes are cached separately', () {
    const a = CoverResizeImageKey('url', 100);
    const b = CoverResizeImageKey('url', 100);
    const c = CoverResizeImageKey('url', 200);
    expect(a, b);
    expect(a == c, isFalse);
  });
}
