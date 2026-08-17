import 'package:flutter/material.dart';

import '../../../domain/entities/feedback_option.dart';
import '../../utils/feedback_feed_visuals.dart';

/// The category pill on a card — a coloured dot plus the backend's label
/// ("Bug", "Feature request", …), uppercased.
class FeedbackTypeBadge extends StatelessWidget {
  final FeedbackOptionEntity type;

  const FeedbackTypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final colors = feedbackTypeColors(type.id);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: colors.dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              type.label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.foreground,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The roadmap-status pill ("Under development", "Completed"). The label is the
/// backend's, verbatim — the client only picks the colour and the icon.
/// Messages still at `sent` show no badge.
class FeedbackStatusBadge extends StatelessWidget {
  final FeedbackOptionEntity status;

  const FeedbackStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = feedbackStatusColors(status.id);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            feedbackStatusIcon(status.id),
            size: 12,
            color: colors.foreground,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              status.label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.foreground,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
