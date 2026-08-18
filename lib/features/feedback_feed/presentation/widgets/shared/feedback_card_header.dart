import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/feedback_message.dart';
import 'feedback_avatar.dart';
import 'feedback_badges.dart';

/// The top row shared by both card styles: avatar, author, timestamp and the
/// category badge. The viewer's own cards get a "you" marker after the
/// username.
class FeedbackCardHeader extends StatelessWidget {
  final FeedbackMessageEntity message;

  /// The relative stamp under the username ("6d ago" / "shipped 3d ago").
  final String timeLabel;

  const FeedbackCardHeader({
    super.key,
    required this.message,
    required this.timeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FeedbackAvatar(
          username: message.author.username,
          avatarUrl: message.author.avatarUrl,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      message.author.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (message.viewerIsAuthor) ...[
                    const SizedBox(width: 5),
                    Text(
                      '· ${l10n.feedbackFeedYou}',
                      style: const TextStyle(
                        color: AppColors.mute,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                timeLabel,
                style: const TextStyle(
                  color: AppColors.mute,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Fixed-width, flush to the row's end: renders at its natural size
        // for the full label, and the Expanded author column above yields
        // whatever space it needs.
        FeedbackTypeBadge(type: message.type),
      ],
    );
  }
}
