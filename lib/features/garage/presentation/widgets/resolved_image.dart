import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../utils/image_url_resolver.dart';

/// Displays a car image given its canonical storage path. Resolves the path to
/// a signed URL (cached) then renders it with [CachedNetworkImage]. Shows a
/// shimmer while resolving and a neutral placeholder on failure / null path.
class ResolvedImage extends StatefulWidget {
  final String? storagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ResolvedImage({
    super.key,
    required this.storagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  State<ResolvedImage> createState() => _ResolvedImageState();
}

class _ResolvedImageState extends State<ResolvedImage> {
  late Future<String?> _urlFuture;

  @override
  void initState() {
    super.initState();
    _urlFuture = _resolve();
  }

  @override
  void didUpdateWidget(ResolvedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storagePath != widget.storagePath) {
      _urlFuture = _resolve();
    }
  }

  Future<String?> _resolve() {
    final path = widget.storagePath;
    if (path == null || path.isEmpty) return Future.value(null);
    return getIt<ImageUrlResolver>().resolve(path);
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.zero;
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: FutureBuilder<String?>(
          future: _urlFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _shimmer();
            }
            final url = snapshot.data;
            if (url == null) return _placeholder();
            return CachedNetworkImage(
              imageUrl: url,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              placeholder: (_, _) => _shimmer(),
              errorWidget: (_, _, _) => _placeholder(),
            );
          },
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
