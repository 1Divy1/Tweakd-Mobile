import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/feedback_option.dart';

/// The colour pair behind a category or status badge: [dot]/[foreground] for
/// the marker and text, [background] for the pill.
class FeedbackBadgeColors {
  final Color background;
  final Color foreground;
  final Color dot;

  const FeedbackBadgeColors({
    required this.background,
    required this.foreground,
    required this.dot,
  });
}

// Board-specific accents. They live here rather than in AppColors because only
// this feature's badges use them.
const Color _bugRed = Color(0xFFE5484D);
const Color _bugRedSoft = Color(0xFFFDECEE);
const Color _improvementBlue = Color(0xFF2F6FED);
const Color _improvementBlueSoft = Color(0xFFE8F0FE);
const Color _shippedGreen = Color(0xFF2E7D5B);
const Color _shippedGreenSoft = Color(0xFFE7F3EC);
const Color _progressAmber = Color(0xFF9A6B00);
const Color _progressAmberSoft = Color(0xFFFBF0DA);

/// Colours for a message's **category** badge, keyed off the well-known ids.
/// An unknown id still renders, in neutral ink — the label always comes from
/// the backend.
FeedbackBadgeColors feedbackTypeColors(String typeId) => switch (typeId) {
      kFeedbackTypeBug => const FeedbackBadgeColors(
          background: _bugRedSoft,
          foreground: _bugRed,
          dot: _bugRed,
        ),
      kFeedbackTypeFeatureRequest => FeedbackBadgeColors(
          background: AppColors.accentSoft,
          foreground: AppColors.accentHot,
          dot: AppColors.accent,
        ),
      kFeedbackTypeFeatureImprovement => const FeedbackBadgeColors(
          background: _improvementBlueSoft,
          foreground: _improvementBlue,
          dot: _improvementBlue,
        ),
      _ => FeedbackBadgeColors(
          background: AppColors.line2,
          foreground: AppColors.ink2,
          dot: AppColors.mute,
        ),
    };

/// Colours for a message's **status** badge. `sent` has no badge at all (it is
/// the resting state), so it never reaches this.
FeedbackBadgeColors feedbackStatusColors(String statusId) => switch (statusId) {
      kFeedbackStatusCompleted => const FeedbackBadgeColors(
          background: _shippedGreenSoft,
          foreground: _shippedGreen,
          dot: _shippedGreen,
        ),
      kFeedbackStatusUnderDevelopment => const FeedbackBadgeColors(
          background: _progressAmberSoft,
          foreground: _progressAmber,
          dot: _progressAmber,
        ),
      _ => FeedbackBadgeColors(
          background: AppColors.line2,
          foreground: AppColors.ink2,
          dot: AppColors.mute,
        ),
    };

/// The small leading glyph on a status badge. `completed` gets a tick,
/// everything in flight gets a clock.
IconData feedbackStatusIcon(String statusId) =>
    statusId == kFeedbackStatusCompleted
        ? Icons.check_circle_outline_rounded
        : Icons.schedule_rounded;

/// A message with `sent` status carries no status badge — only the roadmap
/// stages past it are worth calling out.
bool feedbackStatusHasBadge(String statusId) =>
    statusId != kFeedbackStatusSent && statusId.isNotEmpty;
