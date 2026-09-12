import 'package:cached_network_image/cached_network_image.dart';
import 'package:tweakd/features/posts/presentation/widgets/post_detail/pinch_zoom.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';

/// Displays a car image from a permanent public URL (Cloudflare R2).
/// Shows a shimmer while loading and a neutral placeholder on null/error.
class CarImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  /// When true, the image can be pinch-zoomed Instagram-style (reuses the
  /// shared [PinchZoom] used by the post carousel). Placed inside this
  /// widget's own [ClipRRect] so, at rest, the image is clipped to
  /// [borderRadius] like normal — but the lifted overlay used while pinching
  /// isn't part of this clipped subtree, so it can scale past the rounded
  /// bounds instead of staying cut off.
  final bool enableZoom;

  const CarImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.enableZoom = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.zero;
    final url = imageUrl;

    Widget content;
    if (url == null || url.isEmpty) {
      content = _placeholder();
    } else {
      content = CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, _) => _shimmer(),
        errorWidget: (_, _, _) => _placeholder(),
      );
      if (enableZoom) {
        content = PinchZoom(child: content);
      }
    }

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: width,
        height: height,
        child: content,
      ),
    );
  }

  Widget _shimmer() => Shimmer.fromColors(
    baseColor: AppColors.line,
    highlightColor: AppColors.line2,
    child: Container(color: AppColors.line),
  );

  Widget _placeholder() => Container(
    color: AppColors.line2,
    child: Center(
      child: Icon(
        Icons.directions_car_outlined,
        color: AppColors.muteSoft,
        size: 32,
      ),
    ),
  );
}
