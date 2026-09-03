import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import 'profile_section_tabs.dart';

/// Pins [ProfileSectionTabs] under the top bar once the header has scrolled
/// past, so the section switcher is always reachable in a long garage or feed.
///
/// The background is painted opaque: the tabs sit above the scrolling content
/// while pinned, and a transparent delegate would let posts show through.
class ProfileTabsSliverHeader extends SliverPersistentHeaderDelegate {
  final ProfileSection active;
  final ValueChanged<ProfileSection> onChanged;
  final bool showEvents;

  /// The band the tabs occupy. Comes from [heightFor], which grows it with the
  /// user's text size — a hardcoded height clips the labels the moment
  /// someone bumps their font scale.
  final double height;

  const ProfileTabsSliverHeader({
    required this.active,
    required this.onChanged,
    required this.height,
    this.showEvents = false,
  });

  /// The height the tabs need at this context's text scale.
  ///
  /// [ProfileSectionTabs] owns the arithmetic — padding, icon or label,
  /// underline — and caps how far the row grows with the text size, so it can
  /// never outgrow what this reserves.
  static double heightFor(BuildContext context) {
    return ProfileSectionTabs.heightFor(context);
  }

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // The child must be exactly [height] tall. A sliver header lays its child
    // out with the declared extent as a *maximum*, then reports the measured
    // size as paintExtent — and the tabs measure less than that on their own,
    // which trips "layoutExtent exceeds paintExtent" the moment this pins.
    return SizedBox(
      height: height,
      child: ColoredBox(
        color: AppColors.bg,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // The hairline closing the header, drawn under the tabs so the
            // active tab's 2pt underline paints over it rather than sitting a
            // pixel above it.
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ColoredBox(
                color: AppColors.line,
                child: SizedBox(height: 1, width: double.infinity),
              ),
            ),
            ProfileSectionTabs(
              active: active,
              onChanged: onChanged,
              showEvents: showEvents,
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant ProfileTabsSliverHeader oldDelegate) {
    return oldDelegate.active != active ||
        oldDelegate.showEvents != showEvents ||
        oldDelegate.height != height ||
        oldDelegate.onChanged != onChanged;
  }
}
