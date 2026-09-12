import 'package:flutter/material.dart';

import '../../../../../core/shared/widgets/app_shimmer.dart';
import '../../../../../core/theme/app_colors.dart';

/// Placeholder card shown while a thread list loads (matches the loading
/// mock: title bars, an avatar line and tag stubs).
class ForumThreadCardSkeleton extends StatelessWidget {
  const ForumThreadCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Bar(widthFactor: 0.9, height: 14),
            const SizedBox(height: 8),
            const _Bar(widthFactor: 0.55, height: 14),
            const SizedBox(height: 14),
            Row(
              children: const [
                _Circle(size: 18),
                SizedBox(width: 8),
                _Bar(width: 120, height: 10),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: const [
                _Bar(width: 48, height: 20),
                SizedBox(width: 6),
                _Bar(width: 48, height: 20),
                SizedBox(width: 6),
                _Bar(width: 48, height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A full-height list of skeleton cards.
class ForumThreadListSkeleton extends StatelessWidget {
  final int count;

  const ForumThreadListSkeleton({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: count,
      itemBuilder: (_, _) => const ForumThreadCardSkeleton(),
    );
  }
}

class _Bar extends StatelessWidget {
  final double? width;
  final double? widthFactor;
  final double height;

  const _Bar({this.width, this.widthFactor, required this.height});

  @override
  Widget build(BuildContext context) {
    final bar = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.line2,
        borderRadius: BorderRadius.circular(6),
      ),
    );
    if (widthFactor == null) return bar;
    return FractionallySizedBox(widthFactor: widthFactor, child: bar);
  }
}

class _Circle extends StatelessWidget {
  final double size;

  const _Circle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.line2,
        shape: BoxShape.circle,
      ),
    );
  }
}
