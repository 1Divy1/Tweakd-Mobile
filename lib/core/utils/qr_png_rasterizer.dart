import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Rough pixel size of a rasterised QR. Big enough to print a sticker at
/// roughly 17 cm across at 300 dpi, and to fill any phone screen when the user
/// just opens the file to show someone.
const int kQrPngSize = 2048;

/// Draws a QR [svg] into a square PNG of about [size] pixels a side.
///
/// The backend serves the code as a vector, which is the better print master
/// but the worse download: Android's gallery and file viewers cannot decode
/// SVG at all and call a saved one corrupt, and iOS opens it at its intrinsic
/// size — one point per QR module, a stamp about a centimetre wide — so the
/// user has to pinch their way to something readable. A PNG a couple of
/// thousand pixels wide opens everywhere and prints without either problem.
///
/// The scale factor is a whole number of pixels per module rather than an
/// exact fit to [size]: a QR is a grid of hard-edged squares, and only an
/// integer scale keeps every module edge on a pixel boundary, so the code
/// stays crisp instead of picking up the grey half-pixel fringe that costs
/// scanners contrast. The result therefore lands near [size], not on it.
///
/// Throws if the SVG cannot be decoded or has no usable intrinsic size.
Future<Uint8List> rasterizeQrToPng(String svg, {int size = kQrPngSize}) async {
  final vector = await vg.loadPicture(SvgStringLoader(svg), null);
  try {
    // The symbol is square and one SVG unit is one module, quiet zone
    // included — see the backend's QrSvgRenderer.
    final modules = vector.size.width;
    if (modules <= 0 || !modules.isFinite) {
      throw StateError('QR SVG has no usable size: ${vector.size}');
    }
    final scale = math.max(1, size ~/ modules);
    final side = (modules * scale).round();

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    // The white ground is painted here as well as in the SVG: a PNG's alpha
    // channel is otherwise transparent wherever the symbol isn't, and a viewer
    // on a dark background would show a QR no scanner can read.
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, side.toDouble(), side.toDouble()),
      ui.Paint()..color = const ui.Color(0xFFFFFFFF),
    );
    canvas.scale(scale.toDouble());
    canvas.drawPicture(vector.picture);

    final raster = recorder.endRecording();
    try {
      final image = await raster.toImage(side, side);
      try {
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        if (bytes == null) throw StateError('QR PNG encoding returned null');
        return bytes.buffer.asUint8List();
      } finally {
        image.dispose();
      }
    } finally {
      raster.dispose();
    }
  } finally {
    vector.picture.dispose();
  }
}
