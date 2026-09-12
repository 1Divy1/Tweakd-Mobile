import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/feedback_message.dart';
import '../../utils/feedback_feed_format.dart';
import '../shared/feedback_badges.dart';
import '../shared/feedback_card_header.dart';
import '../shared/feedback_staff_response.dart';

/// A shipped request. Read-only by design: the net score is plain text, with no
/// vote buttons and no delete — the work is done and the card is a record of it.
class CompletedFeedbackCard extends StatelessWidget {
  final FeedbackMessageEntity message;

  const CompletedFeedbackCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final staffResponse = message.staffResponse;

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
            timeLabel: feedbackShippedAgo(
              l10n,
              message.completedAt,
              message.createdAt,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FeedbackStatusBadge(status: message.status),
          ),
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
          if (staffResponse != null && staffResponse.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            FeedbackStaffResponse(response: staffResponse),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                Icons.arrow_upward_rounded,
                size: 15,
                color: AppColors.ink2,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.feedbackFeedNetVotes(message.netVotes),
                style: TextStyle(
                  color: AppColors.ink2,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
