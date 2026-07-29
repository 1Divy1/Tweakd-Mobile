import 'package:flutter/material.dart';

import '../../../../../core/shared/widgets/app_shimmer.dart';
import '../../../../../core/theme/app_colors.dart';

/// Full-thread skeleton shown while a thread page loads: the OP block (title,
/// author line, body, tags, action row) followed by a run of reply stubs.
/// Matches the static skeleton style used elsewhere on the forums screen.
class ForumThreadBodySkeleton extends StatelessWidget {
  const ForumThreadBodySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 4, bottom: 24),
        children: const [
          _ThreadHeaderSkeleton(),
          SizedBox(height: 4),
          _ReplyListSkeletonBody(),
        ],
      ),
    );
  }
}

/// Just the replies portion — used while replies (re)load under an already
/// rendered thread header (e.g. changing the reply sort).
class ForumReplyListSkeleton extends StatelessWidget {
  const ForumReplyListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShimmer(
      child: Padding(
        padding: EdgeInsets.only(top: 6),
        child: _ReplyListSkeletonBody(),
      ),
    );
  }
}

class _ThreadHeaderSkeleton extends StatelessWidget {
  const _ThreadHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Title.
          const _Bar(widthFactor: 0.9, height: 20),
          const SizedBox(height: 10),
          const _Bar(widthFactor: 0.5, height: 20),
          const SizedBox(height: 16),
          // Author line.
          Row(
            children: const [
              _Circle(size: 34),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Bar(width: 110, height: 12),
                  SizedBox(height: 6),
                  _Bar(width: 80, height: 10),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Body.
          const _Bar(widthFactor: 0.95, height: 12),
          const SizedBox(height: 8),
          const _Bar(widthFactor: 0.88, height: 12),
          const SizedBox(height: 8),
          const _Bar(widthFactor: 0.6, height: 12),
          const SizedBox(height: 16),
          // Tags.
          Row(
            children: const [
              _Bar(width: 64, height: 22),
              SizedBox(width: 6),
              _Bar(width: 54, height: 22),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.line, height: 1),
          const SizedBox(height: 12),
          // Action row.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _Bar(width: 40, height: 20),
              _Bar(width: 40, height: 20),
              _Bar(width: 40, height: 20),
              _Bar(width: 40, height: 20),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.line, height: 1),
        ],
      ),
    );
  }
}

class _ReplyListSkeletonBody extends StatelessWidget {
  const _ReplyListSkeletonBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [for (var i = 0; i < 4; i++) const _ReplySkeleton()],
    );
  }
}

class _ReplySkeleton extends StatelessWidget {
  const _ReplySkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              _Circle(size: 24),
              SizedBox(width: 8),
              _Bar(width: 100, height: 11),
            ],
          ),
          const SizedBox(height: 10),
          const _Bar(widthFactor: 0.9, height: 11),
          const SizedBox(height: 7),
          const _Bar(widthFactor: 0.65, height: 11),
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
      decoration: const BoxDecoration(
        color: AppColors.line2,
        shape: BoxShape.circle,
      ),
    );
  }
}
