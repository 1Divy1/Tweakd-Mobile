import 'package:flutter/material.dart';

import '../../../../../core/shared/layout/app_layout.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/feedback_sort.dart';

/// The full-width NEWEST / POPULAR / OLDEST segmented control above the board.
/// "Popular" is highest net score first.
class FeedbackSortTabs extends StatelessWidget {
  final FeedbackSort active;
  final ValueChanged<FeedbackSort> onChanged;

  const FeedbackSortTabs({
    super.key,
    required this.active,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12) + AppLayout.inset(context),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _Segment(
            label: l10n.feedbackFeedSortNewest,
            isActive: active == FeedbackSort.newest,
            onTap: () => onChanged(FeedbackSort.newest),
          ),
          _Segment(
            label: l10n.feedbackFeedSortPopular,
            isActive: active == FeedbackSort.popular,
            onTap: () => onChanged(FeedbackSort.popular),
          ),
          _Segment(
            label: l10n.feedbackFeedSortOldest,
            isActive: active == FeedbackSort.oldest,
            onTap: () => onChanged(FeedbackSort.oldest),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        // A transparent hit box so the whole third of the control responds,
        // not just the painted pill.
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.ink : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isActive ? AppColors.inkPanel : AppColors.ink2,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}
