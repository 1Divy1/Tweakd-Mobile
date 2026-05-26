import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';

/// Displays a car image from a permanent public URL (Cloudflare R2).
/// Shows a shimmer while loading and a neutral placeholder on null/error.
class ResolvedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ResolvedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.zero;
    final url = imageUrl;
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: width,
        height: height,
        child: url == null || url.isEmpty
            ? _placeholder()
            : CachedNetworkImage(
                imageUrl: url,
                width: width,
                height: height,
                fit: fit,
                placeholder: (_, _) => _shimmer(),
                errorWidget: (_, _, _) => _placeholder(),
              ),
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
        child: const Center(
          child: Icon(Icons.directions_car_outlined,
              color: AppColors.muteSoft, size: 32),
        ),
      );
}
