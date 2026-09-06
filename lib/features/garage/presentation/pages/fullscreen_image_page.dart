import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/app_pill_button.dart';
import '../widgets/car_image.dart';

/// Arguments for the `/full-screen-image` route: a set of images to swipe
/// between and the index to open on.
class FullscreenImageArgs {
  final List<String> images;
  final int initialIndex;

  const FullscreenImageArgs({required this.images, this.initialIndex = 0});
}

class FullscreenImagePage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullscreenImagePage({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<FullscreenImagePage> createState() => _FullscreenImagePageState();
}

class _FullscreenImagePageState extends State<FullscreenImagePage> {
  late final PageController _pageController;
  late int _currentIndex;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.images.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(6),
          child: AppPillButton(
            icon: Icons.chevron_left_rounded,
            onTap: () => context.pop(),
          ),
        ),
        actions: widget.images.length > 1
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Text(
                      '${_currentIndex + 1} / ${widget.images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: PageView.builder(
        controller: _pageController,
        physics: _isZoomed
            ? const NeverScrollableScrollPhysics()
            : const PageScrollPhysics(),
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
            _isZoomed = false;
          });
        },
        itemBuilder: (context, index) {
          return _ZoomableGalleryImage(
            url: widget.images[index],
            isActive: index == _currentIndex,
            onZoomChanged: (zoomed) {
              if (index == _currentIndex && zoomed != _isZoomed) {
                setState(() => _isZoomed = zoomed);
              }
            },
          );
        },
      ),
    );
  }
}

class _ZoomableGalleryImage extends StatefulWidget {
  final String url;

  /// Whether this page is the one currently on screen. A page that scrolls
  /// away is reset to its unzoomed state so it comes back fitted.
  final bool isActive;
  final ValueChanged<bool> onZoomChanged;

  const _ZoomableGalleryImage({
    required this.url,
    required this.isActive,
    required this.onZoomChanged,
  });

  @override
  State<_ZoomableGalleryImage> createState() => _ZoomableGalleryImageState();
}

class _ZoomableGalleryImageState extends State<_ZoomableGalleryImage> {
  final TransformationController _controller = TransformationController();

  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;
  String? _resolvedUrl;
  // Intrinsic aspect ratio (width / height) of the loaded image, once known.
  double? _imageAspect;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTransformChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImageAspect();
  }

  @override
  void didUpdateWidget(covariant _ZoomableGalleryImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) _resolveImageAspect();
    if (oldWidget.isActive && !widget.isActive) {
      _controller.value = Matrix4.identity();
    }
  }

  /// Loads the image's intrinsic size (shares the cache with the on-screen
  /// [CarImage], so no extra network fetch) to learn its aspect ratio.
  void _resolveImageAspect() {
    if (_resolvedUrl == widget.url && _imageStream != null) return;
    _resolvedUrl = widget.url;
    _imageAspect = null;
    _detachImageStream();
    final listener = ImageStreamListener((ImageInfo info, bool _) {
      final int w = info.image.width;
      final int h = info.image.height;
      if (h > 0 && mounted) setState(() => _imageAspect = w / h);
    });
    _imageStream = CachedNetworkImageProvider(widget.url)
        .resolve(createLocalImageConfiguration(context))
      ..addListener(listener);
    _imageStreamListener = listener;
  }

  void _detachImageStream() {
    if (_imageStream != null && _imageStreamListener != null) {
      _imageStream!.removeListener(_imageStreamListener!);
    }
    _imageStreamListener = null;
  }

  void _handleTransformChanged() {
    widget.onZoomChanged(_controller.value.getMaxScaleOnAxis() > 1.01);
  }

  @override
  void dispose() {
    _detachImageStream();
    _controller.removeListener(_handleTransformChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size viewport = constraints.biggest;
        final EdgeInsets letterbox = letterboxInsets(viewport, _imageAspect);
        return InteractiveViewer(
          transformationController: _controller,
          // Negative margin: the pan boundary is the image rect, not the
          // full-bleed child, so a bar can never be dragged back into view.
          boundaryMargin: EdgeInsets.fromLTRB(
            -letterbox.left,
            -letterbox.top,
            -letterbox.right,
            -letterbox.bottom,
          ),
          minScale: 1,
          maxScale: fullscreenMaxScale(viewport, _imageAspect),
          // The child fills the viewport (rather than shrinking to the
          // contained image), so the InteractiveViewer sizes and clips to the
          // whole screen and the zoom grows the image over the black bars.
          child: CarImage(
            imageUrl: widget.url,
            width: viewport.width,
            height: viewport.height,
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }
}

/// Zoom ceiling for an image that already fills the screen.
const double _baseMaxScale = 5;

/// Hard ceiling, so an extreme panorama can't ask for an absurd zoom.
const double _absoluteMaxScale = 12;

/// The letterbox padding around a [BoxFit.contain] image of [imageAspect]
/// (width / height) inside [viewport], as positive insets.
///
/// The viewer applies the negation as its `boundaryMargin`, so panning is
/// bounded by the image rather than by the empty bars around it: a bar can
/// never be dragged back into view once the zoom has pushed it off.
@visibleForTesting
EdgeInsets letterboxInsets(Size viewport, double? imageAspect) {
  final double? aspect = imageAspect;
  if (aspect == null || aspect <= 0 || viewport.isEmpty || !viewport.isFinite) {
    return EdgeInsets.zero;
  }
  if (viewport.width / viewport.height > aspect) {
    // Image is height-bound; bars sit on the left and right.
    final double displayWidth = viewport.height * aspect;
    return EdgeInsets.symmetric(horizontal: (viewport.width - displayWidth) / 2);
  }
  // Image is width-bound; bars sit on the top and bottom.
  final double displayHeight = viewport.width / aspect;
  return EdgeInsets.symmetric(vertical: (viewport.height - displayHeight) / 2);
}

/// Zoom ceiling for an image of [imageAspect] in [viewport]. At least
/// [_baseMaxScale], but raised for a letterboxed image so the user can always
/// zoom past the point where it covers the screen edge to edge — the whole
/// point of pinching a wide photo is to lose the bars.
@visibleForTesting
double fullscreenMaxScale(Size viewport, double? imageAspect) {
  final double? aspect = imageAspect;
  if (aspect == null || aspect <= 0 || viewport.isEmpty || !viewport.isFinite) {
    return _baseMaxScale;
  }
  final double viewportAspect = viewport.width / viewport.height;
  // Scale at which BoxFit.contain becomes BoxFit.cover.
  final double fillScale = math.max(
    aspect / viewportAspect,
    viewportAspect / aspect,
  );
  return math.max(_baseMaxScale, math.min(fillScale * 1.6, _absoluteMaxScale));
}
