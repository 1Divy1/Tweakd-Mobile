import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Instagram-style pinch-to-zoom.
///
/// While the user pinches with two fingers, [child] lifts into a full-screen
/// [Overlay], scaling around the pinch focal point over the rest of the UI
/// behind a dimming backdrop, then springs back into place when the fingers
/// lift.
///
/// Built to live inside a horizontally-scrolling [PageView]: it only engages
/// once a second finger is down, so single-finger swipes still page the
/// carousel. Use [onZoomChanged] to freeze the surrounding scroll view while a
/// zoom is in progress.
class PinchZoom extends StatefulWidget {
  final Widget child;
  final ValueChanged<bool>? onZoomChanged;
  final double maxScale;

  const PinchZoom({
    super.key,
    required this.child,
    this.onZoomChanged,
    this.maxScale = 4.0,
  });

  @override
  State<PinchZoom> createState() => _PinchZoomState();
}

class _PinchZoomState extends State<PinchZoom>
    with SingleTickerProviderStateMixin {
  final _key = GlobalKey();
  OverlayEntry? _entry;
  // Resolved while the element is active (never via context at gesture time):
  // looking up an ancestor on a deactivated element — e.g. a swiped-away
  // PageView page — throws "deactivated widget's ancestor is unsafe".
  OverlayState? _overlay;
  late final AnimationController _reset = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  )..addListener(() {
      if (_entry?.mounted ?? false) _entry!.markNeedsBuild();
    });

  Offset _origin = Offset.zero; // child top-left in global coordinates
  Size _size = Size.zero;
  Offset _startFocal = Offset.zero;
  Offset _focal = Offset.zero;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _reset.addStatusListener((status) {
      if (status == AnimationStatus.completed) _endZoom();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _overlay = Overlay.of(context, rootOverlay: true);
  }

  @override
  void dispose() {
    _removeOverlay();
    _reset.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _entry?.remove();
    _entry = null;
  }

  /// Tears the lifted image down and re-enables the surrounding scroll view.
  void _endZoom() {
    if (_entry == null) return;
    _removeOverlay();
    _reset.value = 0;
    widget.onZoomChanged?.call(false);
  }

  void _onStart(ScaleStartDetails d) {
    if (d.pointerCount < 2 || _entry != null || _overlay == null) return;
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    _origin = box.localToGlobal(Offset.zero);
    _size = box.size;
    _startFocal = d.focalPoint;
    _focal = d.focalPoint;
    _scale = 1.0;
    _reset.stop();
    _reset.value = 0;
    _insertOverlay();
    widget.onZoomChanged?.call(true);
  }

  void _onUpdate(ScaleUpdateDetails d) {
    if (_entry == null) return;
    _scale = d.scale.clamp(1.0, widget.maxScale);
    _focal = d.focalPoint;
    _entry!.markNeedsBuild();
  }

  void _onEnd(ScaleEndDetails d) {
    if (_entry == null) return;
    // Spring back; _endZoom() runs on the completed status listener.
    _reset.forward(from: 0);
  }

  void _insertOverlay() {
    _entry = OverlayEntry(builder: (_) {
      // `_reset` runs 0 -> 1 on release; `t` eases the transform back to rest.
      final t = _reset.isAnimating ? (1 - _reset.value) : 1.0;
      final scale = 1 + (_scale - 1) * t;
      final pan = (_focal - _startFocal) * t;
      final dim = ((scale - 1) * 0.4).clamp(0.0, 0.7);
      return Positioned.fill(
        child: IgnorePointer(
          child: Stack(
            children: [
              Positioned.fill(
                child: ColoredBox(color: Colors.black.withValues(alpha: dim)),
              ),
              Positioned(
                left: _origin.dx,
                top: _origin.dy,
                width: _size.width,
                height: _size.height,
                child: Transform(
                  transform: _matrix(scale, pan),
                  child: widget.child,
                ),
              ),
            ],
          ),
        ),
      );
    });
    _overlay!.insert(_entry!);
  }

  Matrix4 _matrix(double scale, Offset pan) {
    final focalLocal = _startFocal - _origin; // pinch point within the child
    return Matrix4.translationValues(pan.dx, pan.dy, 0)
      ..multiply(Matrix4.translationValues(focalLocal.dx, focalLocal.dy, 0))
      ..multiply(Matrix4.diagonal3Values(scale, scale, 1))
      ..multiply(Matrix4.translationValues(-focalLocal.dx, -focalLocal.dy, 0));
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        _TwoFingerScaleRecognizer:
            GestureRecognizerFactoryWithHandlers<_TwoFingerScaleRecognizer>(
          () => _TwoFingerScaleRecognizer(),
          (r) => r
            ..onStart = _onStart
            ..onUpdate = _onUpdate
            ..onEnd = _onEnd,
        ),
      },
      child: KeyedSubtree(key: _key, child: widget.child),
    );
  }
}

/// A [ScaleGestureRecognizer] that ignores single-finger movement so an
/// ancestor [PageView] keeps its horizontal swipe; it only accumulates a
/// gesture once a second pointer joins (a real pinch).
class _TwoFingerScaleRecognizer extends ScaleGestureRecognizer {
  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent && pointerCount < 2) {
      // Drop single-finger drag so the PageView can win the gesture arena.
      return;
    }
    super.handleEvent(event);
  }
}
