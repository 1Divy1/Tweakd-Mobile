import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

/// Full-section error state with a retry action.
class ForumErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ForumErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: AppColors.muteSoft, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.mute,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accent,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: Text(l10n.forumsRetry),
            ),
          ],
        ),
      ),
    );
  }
}
