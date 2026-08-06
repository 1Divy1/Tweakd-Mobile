import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' show MbxImage;

import '../../../../core/theme/app_colors.dart';

/// Paints the circular logo markers the map draws for businesses.
///
/// Mapbox symbols are raster images registered on the style by id, so a "logo
/// in a circle" can't be a Flutter widget — it has to be composited into
/// pixels here and handed to `style.addStyleImage`. Everything is drawn once
/// per business and cached by the [BusinessMarkerFactory] that owns it.
///
/// Logos live on a public CDN, so they're fetched with plain `http` rather than
/// the app's Dio client — routing them through `AuthInterceptor` would attach
/// the user's JWT to a third-party host.
class BusinessMarkerFactory {
  /// Device-pixel scale the markers are rasterised at. Passed to Mapbox as the
  /// image's pixel ratio, so the same bitmap stays crisp on any screen.
  static const double scale = 3.0;

  /// Marker diameter in logical pixels, ring included.
  static const double _diameter = 46.0;

  /// White ring around the logo — what separates the marker from the basemap.
  static const double _ringWidth = 3.0;

  static const double _shadowBlur = 4.0;
  static const double _shadowOffsetY = 1.5;

  /// Padding around the canvas so the shadow isn't clipped.
  static const double _pad = 4.0;

  final http.Client _client;

  BusinessMarkerFactory({http.Client? client})
      : _client = client ?? http.Client();

  /// A marker showing [logoUrl] inside a white ring.
  ///
  /// Returns null when the logo can't be fetched or decoded — the caller keeps
  /// the placeholder marker rather than showing nothing.
  Future<MbxImage?> buildLogoMarker(String logoUrl) async {
    final logo = await _decodeLogo(logoUrl);
    if (logo == null) return null;
    try {
      return _paint(logo);
    } finally {
      logo.dispose();
    }
  }

  /// The marker used before a logo has loaded, and for businesses that never
  /// uploaded one. Shared by every pin, so it's built once.
  Future<MbxImage> buildPlaceholderMarker() => _paint(null);

  Future<ui.Image?> _decodeLogo(String logoUrl) async {
    if (logoUrl.isEmpty) return null;
    final uri = Uri.tryParse(logoUrl);
    if (uri == null || !uri.hasScheme) return null;

    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) return null;

      // Decode straight to marker size — full-resolution logos would be
      // downscaled by the GPU anyway, and this keeps peak memory small when a
      // screenful of pins loads at once.
      final target = ((_diameter - _ringWidth * 2) * scale).round();
      final codec = await ui.instantiateImageCodec(
        response.bodyBytes,
        targetWidth: target,
        targetHeight: target,
      );
      final frame = await codec.getNextFrame();
      codec.dispose();
      return frame.image;
    } catch (_) {
      // A logo that won't load is cosmetic — fall back to the placeholder.
      return null;
    }
  }

  Future<MbxImage> _paint(ui.Image? logo) async {
    final side = (_diameter + _pad * 2) * scale;
    final centre = Offset(side / 2, side / 2);
    final outerRadius = (_diameter / 2) * scale;
    final innerRadius = outerRadius - _ringWidth * scale;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawCircle(
      centre.translate(0, _shadowOffsetY * scale),
      outerRadius,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.22)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, _shadowBlur * scale),
    );

    canvas.drawCircle(centre, outerRadius, Paint()..color = AppColors.surface);

    if (logo == null) {
      _paintPlaceholderGlyph(canvas, centre, innerRadius);
    } else {
      _paintLogo(canvas, logo, centre, innerRadius);
    }

    final picture = recorder.endRecording();
    final size = side.round();
    final image = await picture.toImage(size, size);
    picture.dispose();

    // PNG, not `rawRgba`, despite what MbxImage's doc comment says: that
    // describes the native SDK's `Image`, but the pigeon bridge decodes these
    // bytes as an image *file* first — `BitmapFactory.decodeByteArray` on
    // Android, `UIImage(data:scale:)` on iOS. Raw pixels make both return null,
    // and Android then dereferences it (NPE in StyleController.addStyleImage).
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    return MbxImage(
      width: size,
      height: size,
      data: bytes!.buffer.asUint8List(),
    );
  }

  void _paintLogo(
    Canvas canvas,
    ui.Image logo,
    Offset centre,
    double radius,
  ) {
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: centre, radius: radius)));

    // Cover, not fit: a letterboxed logo inside a circle looks like a mistake.
    final side = math.min(logo.width, logo.height).toDouble();
    final src = Rect.fromCenter(
      center: Offset(logo.width / 2, logo.height / 2),
      width: side,
      height: side,
    );
    canvas.drawImageRect(
      logo,
      src,
      Rect.fromCircle(center: centre, radius: radius),
      Paint()..filterQuality = FilterQuality.medium,
    );
    canvas.restore();
  }

  void _paintPlaceholderGlyph(Canvas canvas, Offset centre, double radius) {
    canvas.drawCircle(centre, radius, Paint()..color = AppColors.accentSoft);

    final glyph = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.storefront_rounded.codePoint),
        style: TextStyle(
          fontSize: radius * 1.1,
          fontFamily: Icons.storefront_rounded.fontFamily,
          package: Icons.storefront_rounded.fontPackage,
          color: AppColors.accent,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    glyph.paint(
      canvas,
      centre - Offset(glyph.width / 2, glyph.height / 2),
    );
    glyph.dispose();
  }

  void dispose() => _client.close();
}
