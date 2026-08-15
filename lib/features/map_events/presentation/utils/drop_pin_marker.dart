import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:car_social_media_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Paints the teardrop pin the user drops onto the map when picking an event
/// location.
///
/// This is a Mapbox annotation image rather than a Flutter widget, because the
/// dropped pin has to stay glued to its geographic point while the map pans
/// and zooms underneath it. A Flutter overlay would need its screen position
/// recomputed on every camera frame; an annotation is moved by the renderer
/// for free.
///
/// The shape is built as **one path** — tip, tangent lines, arc over the head
/// — rather than a circle plus a triangle. Two overlapping shapes share a
/// seam, and the white outline would draw straight through it.
class DropPinMarker {
  /// Device-pixel scale, matching `MapMarkerFactory.scale` so pins from both
  /// sources stay equally crisp.
  static const double scale = 3.0;

  static const double _headRadius = 11.0;
  static const double _outline = 2.5;

  /// Distance from the head's centre down to the tip.
  static const double _tailLength = 30.0;

  /// Room around the artwork so the shadow isn't clipped.
  static const double _pad = 4.0;

  static const double _shadowBlur = 3.5;
  static const double _shadowOffsetY = 2.0;

  /// The white dot in the head, which is what makes the shape read as a map
  /// pin rather than a balloon.
  static const double _eyeRadius = 3.6;

  /// Cached because the bitmap never varies — one pin, one colour, one size.
  static Uint8List? _cached;

  /// PNG bytes for [PointAnnotationOptions.image], anchored at the tip
  /// (`IconAnchor.BOTTOM`).
  ///
  /// PNG rather than raw RGBA: the pigeon bridge decodes these bytes as an
  /// image *file* on both platforms, and raw pixels make the decode return
  /// null. `MapMarkerFactory._paint` documents the same trap.
  static Future<Uint8List> bytes() async {
    final cached = _cached;
    if (cached != null) return cached;

    final centre = Offset(
      (_pad + _outline + _headRadius) * scale,
      (_pad + _outline + _headRadius) * scale,
    );
    final radius = _headRadius * scale;
    final tipY = centre.dy + _tailLength * scale;

    final width = ((_pad + _outline + _headRadius) * 2 * scale).round();
    final height = (tipY + (_pad + _outline) * scale).round();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final path = _teardrop(centre, radius, tipY);

    canvas.drawPath(
      path.shift(Offset(0, _shadowOffsetY * scale)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.28)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, _shadowBlur * scale),
    );

    canvas.drawPath(path, Paint()..color = AppColors.accent);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _outline * scale
        ..color = AppColors.surface,
    );
    canvas.drawCircle(
      centre,
      _eyeRadius * scale,
      Paint()..color = AppColors.surface,
    );

    final picture = recorder.endRecording();
    final rendered = await picture.toImage(width, height);
    picture.dispose();

    final data = await rendered.toByteData(format: ui.ImageByteFormat.png);
    rendered.dispose();

    return _cached = data!.buffer.asUint8List();
  }

  /// Head circle plus the two tangent lines that meet at the tip, as a single
  /// closed path.
  static Path _teardrop(Offset centre, double radius, double tipY) {
    final tip = Offset(centre.dx, tipY);
    final distance = tipY - centre.dy;

    // Where the tangents from the tip touch the head. Measured off the
    // straight-down direction (π/2 in screen coordinates, y growing downward).
    final theta = math.acos(radius / distance);
    final start = math.pi / 2 + theta;

    final first = Offset(
      centre.dx + radius * math.cos(start),
      centre.dy + radius * math.sin(start),
    );

    return Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(first.dx, first.dy)
      // Over the top of the head and back down to the mirrored tangent point.
      ..arcTo(
        Rect.fromCircle(center: centre, radius: radius),
        start,
        2 * math.pi - 2 * theta,
        false,
      )
      ..close();
  }
}
