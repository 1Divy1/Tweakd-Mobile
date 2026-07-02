import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// The icon + one-line description shown for a feedback type in the picker and
/// the selected-type field. Keyed off the backend type [id] so the copy tracks
/// the known categories, with a graceful fallback for any unknown id.
typedef FeedbackTypeVisual = ({IconData icon, String? description});

FeedbackTypeVisual feedbackTypeVisual(AppLocalizations l10n, String id) {
  switch (id) {
    case 'bug':
      return (
        icon: Icons.warning_amber_rounded,
        description: l10n.feedbackTypeBugDesc,
      );
    case 'feature_request':
    case 'feature':
      return (
        icon: Icons.auto_awesome,
        description: l10n.feedbackTypeFeatureDesc,
      );
    case 'general':
      return (
        icon: Icons.chat_bubble_outline,
        description: l10n.feedbackTypeGeneralDesc,
      );
    default:
      return (icon: Icons.feedback_outlined, description: null);
  }
}
