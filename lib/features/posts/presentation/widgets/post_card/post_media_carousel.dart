import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/post_image.dart';
import '../post_detail/pinch_zoom.dart';
import 'post_image_viewer.dart';

/// Shared post media: a swipeable image carousel with a `1/n` counter pill and
/// page dots. Reused by the feed card (cover fit, rounded, with the design's
/// "peek" of the next image) and the post detail view (contain fit, pinch zoom).
class PostMediaCarousel extends StatefulWidget {
  final List<PostImageEntity> images;
  final double aspectRatio;
  final BoxFit fit;
  final BorderRadius borderRadius;

  /// When true, each image can be pinch-zoomed and page swiping is locked
  /// while a zoom gesture is active (used on the detail screen).
  final bool enableZoom;

  /// When true, the current image is left-aligned and the next one peeks in on
  /// the right with a small gap — the overlapping look from the feed design.
  final bool peek;

  /// Single-finger tap on the image. Coexists with [enableZoom]: a tap never
  /// has a second pointer, so the pinch recognizer leaves it alone. When null
  /// (the default), tapping opens the full-screen image viewer popup over the
  /// current screen, starting at the tapped page.
  final VoidCallback? onTap;

  const PostMediaCarousel({
    super.key,
    required this.images,
    this.aspectRatio = 4 / 5,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
    this.enableZoom = false,
    this.peek = false,
    this.onTap,
  });

  @override
  State<PostMediaCarousel> createState() => _PostMediaCarouselState();
}

class _PostMediaCarouselState extends State<PostMediaCarousel> {
  static const double _peekFraction = 0.9;
  static const double _peekGap = 10;

  late final PageController _controller;
  late final bool _peeking;
  int _page = 0;
  bool _zooming = false;

  @override
  void initState() {
    super.initState();
    // Peeking only makes sense with more than one image; a single image should
    // still fill the frame, so it uses a full-width viewport.
    _peeking = widget.peek && widget.images.length > 1;
    _controller = PageController(
      viewportFraction: _peeking ? _peekFraction : 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;

    if (images.isEmpty) {
      return AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: ClipRRect(
          borderRadius: widget.borderRadius,
          child: const ColoredBox(
            color: AppColors.bg,
            child: Center(
              child:
                  Icon(Icons.image_outlined, color: AppColors.muteSoft, size: 40),
            ),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          // The active page is centered in the viewport (padEnds: true). With a
          // peeking viewport fraction its neighbours show on both sides, so the
          // gap between the active image's edge and the card edge — where the
          // counter/dots are anchored — is symmetric.
          final sideInset = _peeking
              ? width * (1 - _peekFraction) / 2 + _peekGap / 2
              : 0.0;

          return Stack(
            children: [
              PageView.builder(
                controller: _controller,
                physics: _zooming
                    ? const NeverScrollableScrollPhysics()
                    : const PageScrollPhysics(),
                itemCount: images.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _peeking ? _peekGap / 2 : 0,
                  ),
                  child: ClipRRect(
                    borderRadius: widget.borderRadius,
                    child: _buildImage(images[i], i, width),
                  ),
                ),
              ),
              if (images.length > 1)
                Positioned(
                  top: 12,
                  right: sideInset + 12,
                  child: _CounterPill(page: _page, total: images.length),
                ),
              if (images.length > 1)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 12,
                  child: _PageDots(count: images.length, active: _page),
                ),
            ],
          );
        },
      ),
    );
  }

  void _openFullScreen(int index) {
    showPostImageViewer(
      context,
      images: widget.images,
      initialIndex: index,
    );
  }

  Widget _buildImage(PostImageEntity image, int index, double viewportWidth) {
    // Cap decode resolution to what the carousel actually displays — full
    // source-resolution images decoded for a feed-sized thumbnail is a real
    // memory/jank cost during fast scrolling.
    final cacheWidth =
        (viewportWidth * MediaQuery.devicePixelRatioOf(context)).round();
    final picture = CachedNetworkImage(
      imageUrl: image.imageUrl,
      fit: widget.fit,
      width: double.infinity,
      height: double.infinity,
      memCacheWidth: cacheWidth,
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: (_, _) => const ColoredBox(color: AppColors.bg),
      errorWidget: (_, _, _) => const ColoredBox(
        color: AppColors.bg,
        child: Center(
          child: Icon(Icons.broken_image_outlined,
              color: AppColors.muteSoft, size: 36),
        ),
      ),
    );

    Widget child = picture;
    if (widget.enableZoom) {
      child = PinchZoom(
        onZoomChanged: (z) => setState(() => _zooming = z),
        child: child,
      );
    }
    child = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap ?? () => _openFullScreen(index),
      child: child,
    );
    return child;
  }
}

class _CounterPill extends StatelessWidget {
  final int page;
  final int total;
  const _CounterPill({required this.page, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(150),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${page + 1}/$total',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  final int count;
  final int active;
  const _PageDots({required this.count, required this.active});

  @override
  Widget build(BuildContext context) {
    final shown = count.clamp(0, 7);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < shown; i++)
          Container(
            width: i == active ? 16 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: i == active ? Colors.white : Colors.white.withAlpha(130),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );
  }
}
