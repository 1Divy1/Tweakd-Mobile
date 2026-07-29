import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme/app_colors.dart';

/// Wraps a skeleton subtree in the app's standard shimmer sweep. The child's
/// opaque placeholder shapes (bars, circles, blocks) act as the mask, so only
/// those animate.
///
/// Wrap **only** the placeholder shapes — keep decorative surfaces (card
/// backgrounds/borders, page backgrounds) outside, or the whole surface
/// becomes one uniform shimmering block and loses its internal detail.
class AppShimmer extends StatelessWidget {
  final Widget child;

  const AppShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.line,
      highlightColor: AppColors.line2,
      child: child,
    );
  }
}
