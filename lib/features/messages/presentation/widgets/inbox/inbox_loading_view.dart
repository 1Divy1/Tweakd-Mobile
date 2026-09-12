import 'package:flutter/material.dart';

import '../../../../../core/shared/widgets/app_shimmer.dart';
import '../../../../../core/theme/app_colors.dart';

/// Skeleton placeholder shown while the DM inbox loads. Mirrors the
/// conversation list (avatar, name + preview lines, trailing timestamp) using
/// the same static skeleton style as the forums screen.
class InboxLoadingView extends StatelessWidget {
  const InboxLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 16),
        itemCount: 8,
        itemBuilder: (_, _) => const _ConversationSkeleton(),
      ),
    );
  }
}

class _ConversationSkeleton extends StatelessWidget {
  const _ConversationSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: const [
          _Circle(size: 56),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bar(width: 130, height: 13),
                SizedBox(height: 8),
                _Bar(widthFactor: 0.7, height: 11),
              ],
            ),
          ),
          SizedBox(width: 12),
          _Bar(width: 34, height: 10),
        ],
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
