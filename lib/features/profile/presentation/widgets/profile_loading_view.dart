import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/shared/widgets/app_shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import 'shared/profile_content_frame.dart';
import 'shared/profile_header.dart';

/// Skeleton placeholder shown while a profile loads (used by both the own and
/// public profile pages). Mirrors the profile layout — avatar with the name
/// and counts beside it, bio, action button, badge strip, section tabs and the
/// garage cards behind the default tab — using the same static skeleton style
/// as the forums screen.
class ProfileLoadingView extends StatelessWidget {
  const ProfileLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    // Framed like the loaded page, so a tablet doesn't show a full-width
    // skeleton that snaps to a centred column when the data lands.
    return ProfileContentFrame(
      child: AppShimmer(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // Avatar, with the name and follower counts beside it.
                Row(
                  children: [
                    const _Circle(size: ProfileHeader.avatarSize),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          _Bar(width: 150, height: 18),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _Stat()),
                              Expanded(child: _Stat()),
                              Expanded(child: _Stat()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Bio lines.
                const _Bar(height: 11),
                const SizedBox(height: 8),
                const _Bar(height: 11),
                const SizedBox(height: 8),
                const _Bar(width: 200, height: 11),
                const SizedBox(height: 20),
                // The two action pills.
                Row(
                  children: const [
                    Expanded(child: _Pill()),
                    SizedBox(width: 10),
                    Expanded(child: _Pill()),
                  ],
                ),
                const SizedBox(height: 20),
                // Badge strip.
                const _BadgeStrip(),
                const SizedBox(height: 20),
                // Section tabs — icons only, evenly spread.
                Row(
                  children: const [
                    Expanded(child: Center(child: _Bar(width: 26, height: 26))),
                    Expanded(child: Center(child: _Bar(width: 26, height: 26))),
                    Expanded(child: Center(child: _Bar(width: 26, height: 26))),
                  ],
                ),
                const SizedBox(height: 12),
                // The hairline closing the tab bar.
                const _Bar(height: 1),
                const SizedBox(height: 22),
                // Garage is the default tab, so the body is car cards.
                const _CarCard(),
                const SizedBox(height: 12),
                const _CarCard(),
                const SizedBox(height: 24),
              ],
            ),
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
    // Centred under one of three equal columns, like the loaded row.
    return Column(
      children: const [
        _Bar(width: 44, height: 16),
        SizedBox(height: 6),
        _Bar(width: 62, height: 10),
      ],
    );
  }
}

class _BadgeStrip extends StatelessWidget {
  const _BadgeStrip();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Same cap as the real strip, so the skeleton doesn't jump on a
        // tablet when the badges land.
        final slot = math.min(constraints.maxWidth / 5, 84.0);
        final diameter = (slot - 12).clamp(40.0, 64.0);
        return Row(
          children: [
            for (var i = 0; i < 5; i++)
              SizedBox(
                width: slot,
                child: Column(
                  children: [
                    _Circle(size: diameter),
                    const SizedBox(height: 8),
                    _Bar(width: diameter * 0.7, height: 8),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CarCard extends StatelessWidget {
  const _CarCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(color: AppColors.line2),
          ),
        ),
        const SizedBox(height: 12),
        const _Bar(width: 180, height: 16),
        const SizedBox(height: 8),
        const _Bar(width: 130, height: 11),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.line2,
        borderRadius: BorderRadius.circular(18),
      ),
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
      decoration: BoxDecoration(
        color: AppColors.line2,
        shape: BoxShape.circle,
      ),
    );
  }
}
