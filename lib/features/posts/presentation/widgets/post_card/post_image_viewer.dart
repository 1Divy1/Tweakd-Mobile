import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/shared/widgets/app_pill_button.dart';
import '../../../domain/entities/post_image.dart';

/// Opens [PostImageViewer] as a popup layered over the current screen rather
/// than as a new route destination: the route is non-opaque, so the page
/// underneath stays mounted and visible until the viewer's own black backdrop
/// fades in over it.
Future<void> showPostImageViewer(
  BuildContext context, {
  required List<PostImageEntity> images,
  int initialIndex = 0,
}) {
  return Navigator.of(context, rootNavigator: true).push<void>(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, animation, _) => FadeTransition(
        opacity: animation,
        child: PostImageViewer(images: images, initialIndex: initialIndex),
      ),
    ),
  );
}

/// Full-screen popup for a post's images, opened by tapping an image in
/// `PostMediaCarousel`. Fills the screen with black behind the image, supports
/// pinch- and double-tap-zoom, swipes between images while at rest scale, and
/// dismisses on a downward drag.
class PostImageViewer extends StatefulWidget {
  final List<PostImageEntity> images;
  final int initialIndex;

  const PostImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<PostImageViewer> createState() => _PostImageViewerState();
}

class _PostImageViewerState extends State<PostImageViewer> {
  /// Drag distance past which releasing dismisses the viewer.
  static const double _dismissThreshold = 120;

  /// Drag distance at which the backdrop reaches its most transparent, so the
  /// page underneath shows through as the image is pulled away.
  static const double _fadeDistance = 320;

  late final PageController _pageController;
  late int _page;
  bool _zoomed = false;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _page = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() => _dragOffset += details.delta.dy);
  }

  void _onDragEnd(DragEndDetails details) {
    final flung = details.velocity.pixelsPerSecond.dy.abs() > 700;
    if (_dragOffset.abs() > _dismissThreshold || flung) {
      Navigator.of(context).pop();
    } else {
      setState(() => _dragOffset = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    // The backdrop only thins out while the viewer is being dragged away;
    // at rest it is solid black everywhere the image does not cover.
    final fade = (_dragOffset.abs() / _fadeDistance).clamp(0.0, 1.0);
    final backdropAlpha = (255 * (1 - fade * 0.75)).round();

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: Colors.black.withAlpha(backdropAlpha)),
          // Vertical drags dismiss, horizontal ones fall through to the
          // PageView. While zoomed in both belong to the InteractiveViewer,
          // so the handlers detach and panning wins the gesture arena.
          GestureDetector(
            onVerticalDragUpdate: _zoomed ? null : _onDragUpdate,
            onVerticalDragEnd: _zoomed ? null : _onDragEnd,
            child: Transform.translate(
              offset: Offset(0, _dragOffset),
              child: PageView.builder(
                controller: _pageController,
                physics: _zoomed
                    ? const NeverScrollableScrollPhysics()
                    : const PageScrollPhysics(),
                itemCount: images.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _ZoomableImage(
                  imageUrl: images[i].imageUrl,
                  onZoomChanged: (zoomed) => setState(() => _zoomed = zoomed),
                ),
              ),
            ),
          ),
          // The chrome stays put while the image is dragged, and hides once
          // the drag is far enough along to read as a dismissal.
          IgnorePointer(
            ignoring: fade > 0,
            child: Opacity(
              opacity: 1 - fade.clamp(0.0, 1.0),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Row(
                    children: [
                      AppPillButton(
                        icon: Icons.close_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      if (images.length > 1)
                        _CounterPill(page: _page, total: images.length),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single image that can be pinch- or double-tap-zoomed in place via
/// [InteractiveViewer]. Panning is enabled only while zoomed in, so a drag at
/// rest scale is left to the parent — to swipe pages or dismiss the viewer —
/// instead of being swallowed as a pan.
class _ZoomableImage extends StatefulWidget {
  final String imageUrl;
  final ValueChanged<bool> onZoomChanged;

  const _ZoomableImage({
    required this.imageUrl,
    required this.onZoomChanged,
  });

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage>
    with SingleTickerProviderStateMixin {
  static const double _doubleTapScale = 3.0;

  final TransformationController _transformController =
      TransformationController();
  late final AnimationController _animController;
  Animation<Matrix4>? _animation;
  TapDownDetails? _doubleTapDetails;
  bool _zoomed = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() => _transformController.value = _animation!.value);
  }

  @override
  void dispose() {
    _animController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  void _setZoomed(bool value) {
    if (value == _zoomed) return;
    setState(() => _zoomed = value);
    widget.onZoomChanged(value);
  }

  /// Zooms to [_doubleTapScale] centred on the tapped point, or back to rest
  /// if already zoomed in.
  void _onDoubleTap() {
    final position = _doubleTapDetails!.localPosition;
    final end = _zoomed
        ? Matrix4.identity()
        : (Matrix4.translationValues(
              -position.dx * (_doubleTapScale - 1),
              -position.dy * (_doubleTapScale - 1),
              0,
            ) *
            Matrix4.diagonal3Values(_doubleTapScale, _doubleTapScale, 1));
    _animation = Matrix4Tween(begin: _transformController.value, end: end)
        .animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward(from: 0);
    _setZoomed(!_zoomed);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (details) => _doubleTapDetails = details,
      onDoubleTap: _onDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformController,
        panEnabled: _zoomed,
        minScale: 1,
        maxScale: 5,
        onInteractionEnd: (_) => _setZoomed(
          _transformController.value.getMaxScaleOnAxis() > 1.01,
        ),
        child: Center(
          child: CachedNetworkImage(
            imageUrl: widget.imageUrl,
            fit: BoxFit.contain,
            placeholder: (_, _) => const Center(
              child: CircularProgressIndicator(color: Colors.white54),
            ),
            errorWidget: (_, _, _) => const Icon(
              Icons.broken_image_outlined,
              color: Colors.white54,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }
}

class _CounterPill extends StatelessWidget {
  final int page;
  final int total;

  const _CounterPill({required this.page, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(150),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${page + 1}/$total',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
