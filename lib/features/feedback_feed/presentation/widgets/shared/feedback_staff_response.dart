import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

/// The team's reply under a completed request: a tinted block with a green
/// rule down its left edge.
class FeedbackStaffResponse extends StatelessWidget {
  final String response;

  const FeedbackStaffResponse({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.bgSoft,
        border: Border(
          left: BorderSide(color: Color(0xFF2E7D5B), width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.feedbackFeedStaffLabel,
            style: TextStyle(
              color: AppColors.mute,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            response,
            style: TextStyle(
              color: AppColors.ink2,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
