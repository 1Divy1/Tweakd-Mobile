import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// The small uppercase heading above each form section, with an optional muted
/// "OPTIONAL" suffix.
class FeedbackSectionLabel extends StatelessWidget {
  final String label;
  final bool optional;

  const FeedbackSectionLabel({
    super.key,
    required this.label,
    this.optional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.ink2,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ),
        if (optional) ...[
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context)!.feedbackOptional,
            style: const TextStyle(
              color: AppColors.muteSoft,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ],
    );
  }
}
