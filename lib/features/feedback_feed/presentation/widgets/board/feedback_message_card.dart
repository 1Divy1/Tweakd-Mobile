import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/feedback_message.dart';
import '../../utils/feedback_feed_format.dart';
import '../../utils/feedback_feed_visuals.dart';
import '../shared/feedback_badges.dart';
import '../shared/feedback_card_header.dart';
import 'feedback_vote_bar.dart';

/// One card on the main board: author, category, an optional roadmap status,
/// the message and the vote controls.
class FeedbackMessageCard extends StatelessWidget {
  final FeedbackMessageEntity message;
  final ValueChanged<int> onVote;
  final VoidCallback onDelete;

  const FeedbackMessageCard({
    super.key,
    required this.message,
    required this.onVote,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FeedbackCardHeader(
            message: message,
            timeLabel: feedbackCreatedAgo(l10n, message.createdAt),
          ),
          // Only stages past "sent" are worth a badge.
          if (feedbackStatusHasBadge(message.status.id)) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: FeedbackStatusBadge(status: message.status),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            message.message,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          FeedbackVoteBar(
            upVotes: message.upVotes,
            downVotes: message.downVotes,
            myVote: message.myVote,
            canDelete: message.canDelete,
            onVote: onVote,
            onDelete: onDelete,
          ),
        ],
      ),
    );
  }
}
