import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// Full-screen error shown when the type/feature pickers fail to load, with a
/// retry affordance.
class FeedbackErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const FeedbackErrorView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.muteSoft,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.feedbackLoadError,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.mute,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: Text(
                l10n.feedbackRetry,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
