import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/app_shimmer.dart';
import '../../../../core/theme/app_colors.dart';

/// Skeleton placeholder shown while a profile loads (used by both the own and
/// public profile pages). Mirrors the profile layout — avatar, identity, bio,
/// stats row, action button, section tabs and a posts grid — using the same
/// static skeleton style as the forums screen.
class ProfileLoadingView extends StatelessWidget {
  const ProfileLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.bg,
      child: AppShimmer(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Avatar.
              const _Circle(size: 96),
              const SizedBox(height: 16),
              // Name + username.
              const _Bar(width: 160, height: 16),
              const SizedBox(height: 8),
              const _Bar(width: 110, height: 12),
              const SizedBox(height: 18),
              // Bio lines.
              const _Bar(width: 240, height: 11),
              const SizedBox(height: 8),
              const _Bar(width: 180, height: 11),
              const SizedBox(height: 22),
              // Stats row.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [_Stat(), SizedBox(width: 40), _Stat()],
              ),
              const SizedBox(height: 22),
              // Action button.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.line2,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Section tabs.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: const [
                    Expanded(child: _Bar(height: 32)),
                    SizedBox(width: 12),
                    Expanded(child: _Bar(height: 32)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Posts grid.
              const _PostsGrid(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _Bar(width: 40, height: 16),
        SizedBox(height: 6),
        _Bar(width: 60, height: 11),
      ],
    );
  }
}

class _PostsGrid extends StatelessWidget {
  const _PostsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      children: [for (var i = 0; i < 9; i++) Container(color: AppColors.line2)],
    );
  }
}

class _Bar extends StatelessWidget {
  final double? width;
  final double height;

  const _Bar({this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.line2,
        borderRadius: BorderRadius.circular(6),
      ),
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
