import 'dart:typed_data' show Uint8List;
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:tweakd/core/utils/qr_png_rasterizer.dart';

/// A stand-in for what `GET …/share/qr.svg` returns: a viewBox measured in
/// modules, matching intrinsic width/height, and the symbol as one run-length
/// encoded path over a white ground. Five modules a side is enough to check
/// the geometry without spelling out a real code.
const _qrSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 5 5" width="5" '
    'height="5" shape-rendering="crispEdges" role="img" aria-label="QR">'
    '<rect width="5" height="5" fill="#ffffff"/>'
    '<path fill="#000000" d="M0 0h2v1h-2zM0 4h5v1h-5z"/>'
    '</svg>';

/// The two bugs this guards against are both invisible until someone opens the
/// downloaded file: a QR saved at its intrinsic size (one pixel per module,
/// unreadable without zooming) and a QR whose modules land on fractional pixel
/// boundaries (a grey fringe that costs scanners contrast).
Future<ui.Image> _decode(Uint8List png) async {
  final codec = await ui.instantiateImageCodec(png);
  final frame = await codec.getNextFrame();
  codec.dispose();
  return frame.image;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('rasterizeQrToPng', () {
    test('scales a module-sized SVG up to a printable PNG', () async {
      final png = await rasterizeQrToPng(_qrSvg);

      final image = await _decode(png);
      addTearDown(image.dispose);

      // 5 modules × an integer scale, as close to 2048 as that allows.
      expect(image.width, 2045);
      expect(image.height, 2045);
    });

    test('keeps every module edge on a whole pixel', () async {
      // Any target that is not a multiple of the module count must round down
      // to one, so no module is drawn across a fraction of a pixel.
      final png = await rasterizeQrToPng(_qrSvg, size: 103);

      final image = await _decode(png);
      addTearDown(image.dispose);

      expect(image.width, 100);
      expect(image.width % 5, 0);
    });

    test('fills the transparent parts of the code with white', () async {
      final png = await rasterizeQrToPng(_qrSvg, size: 50);

      final image = await _decode(png);
      addTearDown(image.dispose);
      final pixels = await image.toByteData(format: ui.ImageByteFormat.rawRgba);

      // Row 1 of the sample is blank, so a pixel there is background: it must
      // be opaque white, not the transparent hole a bare SVG would leave.
      final offset = (image.width * 15 + 1) * 4;
      expect(pixels!.getUint32(offset), 0xFFFFFFFF);
    });

    test('rejects an SVG with no intrinsic size', () async {
      expect(
        rasterizeQrToPng('<svg xmlns="http://www.w3.org/2000/svg"></svg>'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
