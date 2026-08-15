import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' show MbxImage;

import '../../../../core/theme/app_colors.dart';

/// Paints the circular image markers the map draws — a business's logo, an
/// event's cover photo, anything else that is "a picture in a ring".
///
/// Mapbox symbols are raster images registered on the style by id, so this
/// can't be a Flutter widget: it has to be composited into pixels here and
/// handed to `style.addStyleImage`. Each marker is drawn once and cached by the
/// [MapLayerController] that owns the factory.
///
/// Images live on a public CDN, so they're fetched with plain `http` rather
/// than the app's Dio client — routing them through `AuthInterceptor` would
/// attach the user's JWT to a third-party host.
///
/// The only thing that varies between layers is cosmetic ([ringColor] and the
/// glyph shown before an image loads), which is why one factory serves them
/// all instead of a copy per pin kind.
class MapMarkerFactory {
  /// Device-pixel scale the markers are rasterised at. Passed to Mapbox as the
  /// image's pixel ratio, so the same bitmap stays crisp on any screen.
  static const double scale = 3.0;

  /// Marker diameter in logical pixels, ring included.
  static const double _diameter = 46.0;

  /// Ring around the image — what separates the marker from the basemap.
  static const double _ringWidth = 3.0;

  static const double _shadowBlur = 4.0;
  static const double _shadowOffsetY = 1.5;

  /// Padding around the canvas so the shadow isn't clipped.
  static const double _pad = 4.0;

  final http.Client _client;

  /// Colour of the ring. White reads as neutral; the accent is how a live event
  /// stands out from an upcoming one at a glance.
  final Color ringColor;

  /// Drawn (over [placeholderBackground]) until the real image arrives, and
  /// permanently for anything that has no image at all.
  final IconData placeholderIcon;
  final Color placeholderBackground;
  final Color placeholderForeground;

  MapMarkerFactory({
    http.Client? client,
    this.ringColor = AppColors.surface,
    this.placeholderIcon = Icons.storefront_rounded,
    this.placeholderBackground = AppColors.accentSoft,
    this.placeholderForeground = AppColors.accent,
  }) : _client = client ?? http.Client();

  /// A marker showing [imageUrl] inside the ring.
  ///
  /// [ring] overrides [ringColor] for this one marker — how a live event gets
  /// an accent ring while its upcoming neighbours stay white.
  ///
  /// Returns null when the image can't be fetched or decoded — the caller keeps
  /// the placeholder marker rather than showing nothing.
  Future<MbxImage?> buildImageMarker(String imageUrl, {Color? ring}) async {
    final image = await _decodeImage(imageUrl);
    if (image == null) return null;
    try {
      return _paint(image, ring ?? ringColor, placeholderIcon);
    } finally {
      image.dispose();
    }
  }

  /// The marker used before an image has loaded, and for pins that never had
  /// one. Shared by every pin of a layer, so it's built once per layer.
  ///
  /// [icon] overrides [placeholderIcon] — the same factory serves the business
  /// layer (a storefront) and the events layer (a car).
  Future<MbxImage> buildPlaceholderMarker({Color? ring, IconData? icon}) =>
      _paint(null, ring ?? ringColor, icon ?? placeholderIcon);

  Future<ui.Image?> _decodeImage(String imageUrl) async {
    if (imageUrl.isEmpty) return null;
    final uri = Uri.tryParse(imageUrl);
    if (uri == null || !uri.hasScheme) return null;

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) return null;

      // Decode straight to marker size — full-resolution images would be
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
      // An image that won't load is cosmetic — fall back to the placeholder.
      return null;
    }
  }

  Future<MbxImage> _paint(ui.Image? image, Color ring, IconData icon) async {
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

    canvas.drawCircle(centre, outerRadius, Paint()..color = ring);

    if (image == null) {
      _paintPlaceholderGlyph(canvas, centre, innerRadius, icon);
    } else {
      _paintImage(canvas, image, centre, innerRadius);
    }

    final picture = recorder.endRecording();
    final size = side.round();
    final rendered = await picture.toImage(size, size);
    picture.dispose();

    // PNG, not `rawRgba`, despite what MbxImage's doc comment says: that
    // describes the native SDK's `Image`, but the pigeon bridge decodes these
    // bytes as an image *file* first — `BitmapFactory.decodeByteArray` on
    // Android, `UIImage(data:scale:)` on iOS. Raw pixels make both return null,
    // and Android then dereferences it (NPE in StyleController.addStyleImage).
    final bytes = await rendered.toByteData(format: ui.ImageByteFormat.png);
    rendered.dispose();

    return MbxImage(
      width: size,
      height: size,
      data: bytes!.buffer.asUint8List(),
    );
  }

  void _paintImage(
    Canvas canvas,
    ui.Image image,
    Offset centre,
    double radius,
  ) {
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: centre, radius: radius)),
    );

    // Cover, not fit: a letterboxed image inside a circle looks like a mistake.
    final side = math.min(image.width, image.height).toDouble();
    final src = Rect.fromCenter(
      center: Offset(image.width / 2, image.height / 2),
      width: side,
      height: side,
    );
    canvas.drawImageRect(
      image,
      src,
      Rect.fromCircle(center: centre, radius: radius),
      Paint()..filterQuality = FilterQuality.medium,
    );
    canvas.restore();
  }

  void _paintPlaceholderGlyph(
    Canvas canvas,
    Offset centre,
    double radius,
    IconData icon,
  ) {
    canvas.drawCircle(centre, radius, Paint()..color = placeholderBackground);

    final glyph = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: radius * 1.1,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: placeholderForeground,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    glyph.paint(canvas, centre - Offset(glyph.width / 2, glyph.height / 2));
    glyph.dispose();
  }

  void dispose() => _client.close();
}
