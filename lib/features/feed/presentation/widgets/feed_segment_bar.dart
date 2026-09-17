import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../utils/feed_segment.dart';
import '../../../../core/shared/layout/app_layout.dart';

/// The Feed | Forums switch under the home tab's top bar: an iOS sliding
/// segmented control, left-aligned, with an optional [trailing] slot for
/// actions that belong to the active segment (cross-fades on a switch).
class FeedSegmentBar extends StatelessWidget {
  final FeedSegment active;
  final ValueChanged<FeedSegment> onChanged;
  final Widget? trailing;

  const FeedSegmentBar({
    super.key,
    required this.active,
    required this.onChanged,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(16, 4, 16, 8) + AppLayout.inset(context),
      child: ConstrainedBox(
        // Tall enough for the trailing pills, so the list below doesn't jump
        // when they fade in or out.
        constraints: const BoxConstraints(minHeight: 36),
        child: Row(
          children: [
            Flexible(
              child: Align(
                alignment: Alignment.centerLeft,
                child: CupertinoSlidingSegmentedControl<FeedSegment>(
                  groupValue: active,
                  thumbColor: AppColors.surface,
                  // A fixed 5%-black tint reads as a subtle groove in light
                  // mode but nearly vanishes against a near-black page in
                  // dark mode (the surface thumb barely lifts off it either).
                  // AppColors.line already gives exactly this "subtle groove"
                  // in both themes.
                  backgroundColor: AppColors.line,
                  padding: const EdgeInsets.all(2),
                  onValueChanged: (value) {
                    if (value != null) onChanged(value);
                  },
                  children: {
                    FeedSegment.feed: _SegmentLabel(
                      label: l10n.feedSegmentFeed,
                      isActive: active == FeedSegment.feed,
                    ),
                    FeedSegment.forums: _SegmentLabel(
                      label: l10n.forumsTitle,
                      isActive: active == FeedSegment.forums,
                    ),
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: trailing ?? const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentLabel extends StatelessWidget {
  final String label;
  final bool isActive;

  const _SegmentLabel({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isActive ? AppColors.ink : AppColors.ink2,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
