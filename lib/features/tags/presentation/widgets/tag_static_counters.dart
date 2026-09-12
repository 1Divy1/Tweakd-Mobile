import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// One icon (+ optional count) in a [TagStaticCounters] row.
class TagCounter {
  final IconData icon;
  final Color? color;
  final String? label;

  const TagCounter({required this.icon, this.color, this.label});
}

/// The action row of a tagged post, rendered as a **static** preview: same
/// icons and counts as the feed card, but nothing is tappable. Tags are a
/// read-only view of content that lives elsewhere — liking or saving happens
/// on the real post, which the card opens.
class TagStaticCounters extends StatelessWidget {
  final List<TagCounter> items;
  final TagCounter? trailing;

  /// Forum-sized icons and counts (thread cards, comment bubbles) instead of
  /// the larger post action row.
  final bool dense;

  const TagStaticCounters({
    super.key,
    required this.items,
    this.trailing,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final item in items) ...[
          _Counter(counter: item, dense: dense),
          SizedBox(width: dense ? 16 : 20),
        ],
        const Spacer(),
        if (trailing != null) _Counter(counter: trailing!, dense: dense),
      ],
    );
  }
}

class _Counter extends StatelessWidget {
  final TagCounter counter;
  final bool dense;

  const _Counter({required this.counter, required this.dense});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          counter.icon,
          size: dense ? 15 : 22,
          color: counter.color ?? AppColors.ink,
        ),
        if (counter.label != null) ...[
          SizedBox(width: dense ? 4 : 7),
          Text(
            counter.label!,
            style: TextStyle(
              color: dense ? (counter.color ?? AppColors.ink) : AppColors.ink,
              fontSize: dense ? 12 : 14,
              fontWeight: dense ? FontWeight.w700 : FontWeight.w800,
            ),
          ),
        ],
      ],
    );
  }
}
