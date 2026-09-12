import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/app_shimmer.dart';
import '../../../../core/theme/app_colors.dart';

/// Skeleton placeholder shown while the feed loads. Mirrors the feed post
/// card layout (author header, media, action row, caption) so the transition
/// to real content is seamless — matches the static skeleton style used on
/// the forums screen.
class FeedLoadingView extends StatelessWidget {
  const FeedLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: 3,
      itemBuilder: (_, _) => const _FeedPostSkeleton(),
    );
  }
}

class _FeedPostSkeleton extends StatelessWidget {
  const _FeedPostSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.hardEdge,
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author header.
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Row(
                children: const [
                  _Circle(size: 40),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Bar(width: 120, height: 12),
                      SizedBox(height: 6),
                      _Bar(width: 70, height: 10),
                    ],
                  ),
                ],
              ),
            ),
            // Media.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.line2,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            // Action row.
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  _Circle(size: 24),
                  SizedBox(width: 20),
                  _Circle(size: 24),
                  SizedBox(width: 20),
                  _Circle(size: 24),
                  Spacer(),
                  _Circle(size: 24),
                ],
              ),
            ),
            // Caption lines.
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Bar(widthFactor: 0.85, height: 11),
                  SizedBox(height: 8),
                  _Bar(widthFactor: 0.5, height: 11),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
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
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: bar,
    );
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
