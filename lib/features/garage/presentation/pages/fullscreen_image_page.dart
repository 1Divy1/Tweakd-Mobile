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
  final ValueChanged<bool> onZoomChanged;

  const _ZoomableGalleryImage({
    required this.url,
    required this.onZoomChanged,
  });

  @override
  State<_ZoomableGalleryImage> createState() => _ZoomableGalleryImageState();
}

class _ZoomableGalleryImageState extends State<_ZoomableGalleryImage> {
  final TransformationController _controller = TransformationController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTransformChanged);
  }

  void _handleTransformChanged() {
    widget.onZoomChanged(_controller.value.getMaxScaleOnAxis() > 1.01);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTransformChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InteractiveViewer(
        transformationController: _controller,
        minScale: 1,
        maxScale: 5,
        child: CarImage(
          imageUrl: widget.url,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
