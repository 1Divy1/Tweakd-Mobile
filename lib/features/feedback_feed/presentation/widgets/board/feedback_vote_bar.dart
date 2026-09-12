import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../utils/feedback_feed_format.dart';

/// The up/down vote buttons on a board card, plus the author's delete button.
///
/// The arrow the viewer already picked is filled in; tapping it again withdraws
/// the vote. Authors may vote on their own message, so nothing here is disabled
/// for them.
class FeedbackVoteBar extends StatelessWidget {
  final int upVotes;
  final int downVotes;
  final int? myVote;
  final bool canDelete;
  final ValueChanged<int> onVote;
  final VoidCallback onDelete;

  const FeedbackVoteBar({
    super.key,
    required this.upVotes,
    required this.downVotes,
    required this.myVote,
    required this.canDelete,
    required this.onVote,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        _VoteButton(
          icon: Icons.arrow_upward_rounded,
          count: upVotes,
          isActive: myVote == 1,
          activeColor: AppColors.accent,
          onTap: () => onVote(1),
        ),
        const SizedBox(width: 8),
        _VoteButton(
          icon: Icons.arrow_downward_rounded,
          count: downVotes,
          isActive: myVote == -1,
          activeColor: AppColors.ink,
          onTap: () => onVote(-1),
        ),
        const Spacer(),
        if (canDelete)
          Tooltip(
            message: l10n.feedbackFeedDelete,
            child: InkWell(
              onTap: onDelete,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 42,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.line),
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: AppColors.mute,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _VoteButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _VoteButton({
    required this.icon,
    required this.count,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // activeColor may be AppColors.ink (flips black/white with the theme),
    // so its paired foreground must un-invert with it rather than staying a
    // fixed white — otherwise dark mode renders white text on a white pill.
    final foreground = isActive
        ? (activeColor == AppColors.ink ? AppColors.inkPanel : AppColors.onAccent)
        : AppColors.ink2;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 38,
        constraints: const BoxConstraints(minWidth: 74),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? activeColor : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? activeColor : AppColors.line,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: foreground),
            const SizedBox(width: 6),
            Text(
              feedbackCompactCount(count),
              style: TextStyle(
                color: foreground,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
